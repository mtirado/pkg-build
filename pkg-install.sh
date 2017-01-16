#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#PKGAUTOMATE silences already installed check
#PKGOVERWRITE overwrites existing files without prompting
#-----------------------------------------------------------------------------
#TODO more informative output on packages installed
#TODO support arbitrary prefixes
set -e

# either this or dump all package files in root package dir?
PKGGROUP="ungrouped"
#-----------------------------------------------------------------------------
if [ -z "$1" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkg-group>"
	echo "set PKGINSTALL=\"/new/path\" to install to specific directories"
	exit -1
fi
#-----------------------------------------------------------------------------
# make absolute path
if [[ "$1" != /* ]]; then
	PKGDIR="$(pwd)/$1"
else
	PKGDIR="$1"
fi
if [ ! -z "$2" ]; then
	PKGGROUP=$2
fi
# install packages into this location.
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi

CWD=$(pwd)
PKGFILES="$PKGINSTALL/.packages/$PKGGROUP"

#---------- create pkgs directory if needed --------------------------
if [ ! -d "$PKGFILES" ]; then
	mkdir -p $PKGFILES
fi

cd $PKGDIR
for PKGNAME in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do

	EXISTS=0
	TAROPT=""
	TARFILES=""
	cd "$PKGINSTALL"
	# this is for multipass automation to know what has been installed
	# TODO clean this extra file up if distributing package contents
	if [ -e $PKGDIR/$PKGNAME/.pkg-installed ]; then
		if [ -z "$PKGAUTOMATE" ]; then
			echo "skipping $PKGNAME"
		fi
		continue;
	fi

	#----------- check if package name is in use -------------------------
	FIND=$(find "$PKGINSTALL/.packages" -mindepth 1 -maxdepth 2 -name "$PKGNAME" -printf '%f\n')
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

	TARFILES=$(tar -tf "$PKGDIR/$PKGNAME/usr.tar")
	# check for existing files
	for FILE in $(echo "$TARFILES"); do
		if [ ! -d "$FILE" ]; then
			if [ -L "$PKGINSTALL/$FILE" ] || [ -e "$PKGINSTALL/$FILE" ]; then
				echo "$PKGINSTALL/$FILE already exists"
				EXISTS=$((EXISTS + 1))
			fi
		fi
	done
	if [ "$EXISTS" != "0" ]; then
		# TODO we should scan packages to find which one owns file << TODO!
		# no owner should default to default ungrouped package.
		# TODO long winded prompt for each existing file
		echo "-----------------------------------------------------------------"
		echo "$PKGNAME: $EXISTS file(s) already exist in $PKGINSTALL"
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
			ACK="o"
		fi
		TAROPT="-overwrite"
		if [ "$ACK" == "s" ] || [ "$ACK" == "S" ]; then
			continue
		elif [ "$ACK" == "p" ] || [ "$ACK" == "P" ]; then
			TAROPT="-keep-old-files"
		elif [ "$ACK" == "b" ] || [ "$ACK" == "B" ]; then
			# backup duplicate files before overwriting
			for FILE in $(tar -tf "$PKGDIR/$PKGNAME/usr.tar"); do
				if [ ! -d "$FILE" ]; then
					if [ -e "$PKGINSTALL/$FILE" ]; then
						FNAME=$PKGINSTALL/$FILE
						cp -rav $FNAME \
						        $FNAME\.stale-$(date -Iseconds)
					fi
				fi
			done
		elif [ "$ACK" != "d" ] && [ "$ACK" != "D" ]; then
			echo "installation failed."
			exit -1
		fi
	fi

	echo "installing $PKGNAME"
	# construct package file list, if any errors occur after here
	# user will need to manually clean up package file
	for FILE in $(echo "$TARFILES"); do
		if [ ! -d "$FILE" ]; then
			echo $FILE >> $PKGFILES/$PKGNAME
		fi
	done

	#-- TODO some way to chown, prompt for set caps, detect suid/gid bit --
	tar xf "$PKGDIR/$PKGNAME/usr.tar"
	#---------------- fix prefix paths -----------------------------------
	# this breaks things pretty badly. needs a way to adjust path for
	# $PKGINSTALL, currently only works with /usr package installations
	# TODO can just add another global var if no good solutions $PKGPREFIX
	#---------------------------------------------------------------------
	for FILE in $(echo "$TARFILES"); do
		if [ -f "$FILE" ]; then
			if [[ "$FILE" == ./lib/pkgconfig/* ]]; then
				if [ -d "lib/pkgconfig" ]; then
					echo "adjusting  $FILE"
					sed -i "s|prefix=/.*|prefix=/usr|" $FILE
				fi
			elif [[ "$FILE" == ./share/pkgconfig/* ]]; then
				if [ -d "share/pkgconfig" ]; then
					echo "adjusting  $FILE"
					sed -i "s|prefix=/.*|prefix=/usr|" $FILE
				fi
			fi
		fi
	done

	touch $PKGDIR/$PKGNAME/.pkg-installed
done

