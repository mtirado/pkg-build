#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#PKGAUTOMATE silences already installed check
#PKGOVERWRITE overwrites existing files without prompting
#-----------------------------------------------------------------------------
set -e

# either this or dump all package files in root package dir?
PKGGROUP="ungrouped"
#-----------------------------------------------------------------------------
if [ -z "$1" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkg-group>"
	echo ""
	echo "set PKGINSTALL=\"/home/user/blah\" to install to a user owned root."
	echo "prefix is determined by tar filename and can be set when calling"
	echo "pkg-migrate with PKGPREFIX=/flock1 or some other top level directory set"
	echo "deeper prefixes like /usr/local are not supported, yet"
	exit -1
fi
#-----------------------------------------------------------------------------
# make absolute path
if [[ "$1" != /* ]]; then
	_PKG_DIR="$(pwd)/$1"
else
	_PKG_DIR="$1"
fi
if [ ! -z "$2" ]; then
	PKGGROUP=$2
fi
# install packages into this base dir.
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/"
fi

CWD="$(pwd)"

#---------- create pkgs directory if needed --------------------------

cd "$_PKG_DIR"
for PKGNAME in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do

	EXISTS=0
	TAROPT=""
	TARFILES=""
	cd "$PKGINSTALL"
	# this is for multipass automation to know what has been installed
	# TODO clean this extra file up if distributing package contents
	if [ -e "$_PKG_DIR/$PKGNAME/.pkg-installed" ]; then
		if [ -z "$PKGAUTOMATE" ]; then
			echo "skipping $PKGNAME"
		fi
		continue;
	fi

	# prefix is stored as tar file name, root is special case
	COUNT=$(find "$_PKG_DIR/$PKGNAME" -type f -iname '*.tar' | wc -l)
	if [ "$COUNT" != "1" ]; then
		echo "error: pkg-install.sh expects a single tar file"
		echo "$_PKG_DIR/$PKGNAME has $COUNT tar files"
		exit -1
	fi
	TARFILE=$(find "$_PKG_DIR/$PKGNAME" -type f -iname '*.tar')
	TARFILE=$(basename "$TARFILE")
	PREFIX=${TARFILE%.tar}
	if [ "$PREFIX" == "root" ]; then
		PREFIX="/"
	fi
	DEST="$PKGINSTALL/$PREFIX"
	cd "$DEST"


	if [ ! -e "$DEST/.packages" ]; then
		mkdir -p "$DEST/.packages"
	fi
	#----------- check if package name is in use -------------------------
	FIND=$(find "$DEST/.packages" -mindepth 1 -maxdepth 2 -name "$PKGNAME" -printf '%f\n')
	if [ "$FIND" != "" ]; then
		echo "-----------------------------------------------------------------"
		echo " package $PKGNAME already installed. try  running pkg-remove"
		echo " skip installation  (y/n)"
		echo "-----------------------------------------------------------------"
		read -n 1 -s ACK
		if [ "$ACK" == "y" ] || [ "$ACK" == "Y" ]; then
			continue
		else
			echo "installation failed."
			exit -1
		fi
	fi

	TARFILES=$(tar -tf "$_PKG_DIR/$PKGNAME/$TARFILE")
	DUPLICATES=""
	# check for existing files
	for FILE in $(echo "$TARFILES"); do
		if [ ! -d "$FILE" ]; then
			if [ -L "$DEST/$FILE" ] || [ -e "$DEST/$FILE" ]; then
				echo "$DEST/$FILE already exists"
				DUPLICATES+="$FILE "
				EXISTS=$((EXISTS + 1))
			fi
		fi
	done
	if [ "$EXISTS" != "0" ]; then
		# TODO we should scan packages to find which one owns file << TODO!
		# no owner should default to default ungrouped package.
		# TODO long winded prompt for each existing file
		echo ""
		echo "-----------------------------------------------------------------"
		echo "$PKGNAME: $EXISTS file(s) already exist in $DEST"
		echo "you have 5 possible actions:"
		echo ""
		echo "(s)kip installing $PKGNAME"
		echo "(p)reserve  --  do not overwrite existing files."
		echo "(b)ackup    --  create backup file before overwriting"
		echo "(d)estroy   --  overwrite existing files, currently disastrous"
		echo "                if files are used by another package."
		echo "(q)uit installation."
		echo "-----------------------------------------------------------------"
		if [ -z "$PKGOVERWRITE" ]; then
			read -n 1 -s ACK
		else
			ACK="d"
		fi
		TAROPT="--overwrite"
		if [ "$ACK" == "s" ] || [ "$ACK" == "S" ]; then
			continue
		elif [ "$ACK" == "p" ] || [ "$ACK" == "P" ]; then
			#XXX if entire package is preserved no contents file is written
			#though the package will otherwise "succeede", undecided on if
			#this should be considered an error or not...
			FILTER=""
			TAROPT="--skip-old-files"
			# prune preserved files
			for FILE in $(echo "$TARFILES"); do
				for PFILE in $(echo "$DUPLICATES"); do
					if [ "$PFILE" == "$FILE" ]; then
						TARFILES=$(echo "$TARFILES" | sed "\|$PFILE|d")
						echo "preserving $PFILE"
					else
						continue
					fi
				done
			done
		elif [ "$ACK" == "b" ] || [ "$ACK" == "B" ]; then
			# backup duplicate files before overwriting
			for FILE in $(tar -tf "$_PKG_DIR/$PKGNAME/$TARFILE"); do
				if [ ! -d "$FILE" ]; then
					if [ -L "$DEST/$FILE" ] || [ -e "$DEST/$FILE" ]; then
						FNAME="$DEST/$FILE"
						cp -rav "$FNAME" \
						        "$FNAME\.stale-$(date -Iseconds)"
					fi
				fi
			done
		elif [ "$ACK" != "d" ] && [ "$ACK" != "D" ]; then
			echo "installation failed."
			exit -1
		fi
	fi

	#-- TODO some way to chown, prompt for set caps, detect suid/gid bit --
	tar --no-same-owner -x $TAROPT -f "$_PKG_DIR/$PKGNAME/$TARFILE"
	echo "installing $PKGNAME"
	PKGFILES="$DEST/.packages/$PKGGROUP"
	if [ ! -d "$PKGFILES" ]; then
		mkdir -p "$PKGFILES"
	fi

	#---------------- fix prefix paths -----------------------------------
	# this breaks things still!
	# TODO /usr/local will not work or any other deep prefixes, not sure
	# what the best way to do this is now. maybe use backslashes in the
	# tar filename then convert to slashes, or add a prefix file? argh.
	# ALSO, i suppose we should let user override these pkgconfig
	# adjustments, or at least the option to prepend PKGINSTALL
	#---------------------------------------------------------------------
	for FILE in $(echo "$TARFILES"); do
		if [ -f "$FILE" ]; then
			if [[ "$FILE" == ./lib/pkgconfig/* ]]; then
				if [ -d "lib/pkgconfig" ]; then
					echo "adjusting  $FILE"
					sed -i "s|prefix=/.*|prefix=/$PREFIX|" "$FILE"
				fi
			elif [[ "$FILE" == ./share/pkgconfig/* ]]; then
				if [ -d "share/pkgconfig" ]; then
					echo "adjusting  $FILE"
					sed -i "s|prefix=/.*|prefix=/$PREFIX|" "$FILE"
				fi
			fi
		fi
	done

	# construct package file list, if any errors occur after here
	# user will need to manually clean up package file
	for FILE in $(echo "$TARFILES"); do
		if [ ! -d "$FILE" ]; then
			echo "$FILE" >> "$PKGFILES/$PKGNAME"
		fi
	done
	touch "$_PKG_DIR/$PKGNAME/.pkg-installed"
done

