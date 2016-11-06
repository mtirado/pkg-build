#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#PKGAUTOMATE silences already installed check
#-----------------------------------------------------------------------------
#TODO more informative output on packages installed
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
for ITEM in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do

	EXISTS=0
	PKGNAME=$ITEM

	# this is for multipass automation to know what has been installed
	# TODO clean this extra file up if distributing package contents
	if [ -e $PKGDIR/$ITEM/.pkg-installed ]; then
		if [ -z "$PKGAUTOMATE" ]; then
			echo "skipping $ITEM"
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
		exit -1
	fi
	cd $PKGDIR/$ITEM

	# check for existing files
	for FILE in $(find . -mindepth 1); do
		if [ ! -d "$FILE" ]; then
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "$PKGINSTALL/$FILE already exists"
				EXISTS=$((EXISTS + 1))
			fi
		fi
	done
	if [ "$EXISTS" != "0" ]; then
		# TODO we should scan packages to find which one owns file << TODO!
		# no owner should default to a "world" package.
		echo "-----------------------------------------------------------------"
		echo "$PKGNAME: $EXISTS file(s) already exist in $PKGINSTALL"
		echo "you have 5 possible actions:"
		echo ""
		echo "(s)kip installing $PKGNAME"
		echo "(r)emove duplicates -- destroys the newer package files"
		echo "(o)verwrite files   -- overwrite currently disastrous if files"
		echo "                       used by another package."
		echo "(b)ackup file       -- create file.stale-time before overwriting"
		echo "(q)uit installation."
		echo "-----------------------------------------------------------------"
		read -n 1 -s ACK
		if [ "$ACK" == "s" ] || [ "$ACK" == "S" ]; then
			continue
		elif [ "$ACK" == "r" ] || [ "$ACK" == "R" ]; then
			## remove existing files from pkgdir
			for FILE in $(find . -mindepth 1); do
				if [ ! -d "$FILE" ]; then
					if [ -e "$PKGINSTALL/$FILE" ]; then
						rm -v $FILE
					fi
				fi
			done
		elif [ "$ACK" == "b" ] || [ "$ACK" == "B" ]; then
			echo "backup duplicate files."
			# backup duplicate files before overwriting
			# TODO maybe put backups in .packages dir to limit clutter
			for FILE in $(find . -mindepth 1); do
				if [ ! -d "$FILE" ]; then
					if [ -e "$PKGINSTALL/$FILE" ]; then
						FNAME=$PKGINSTALL/$FILE
						cp -v $FNAME \
						      $FNAME\.stale-$(date -Iseconds)
					fi
				fi
			done
		elif [ "$ACK" != "o" ] && [ "$ACK" != "O" ]; then
			echo "installation failed."
			exit -1
		fi
	fi

	#----------- create directories --------------------------------------
	echo "creating directories for $PKGNAME ..."
	for FILE in $(find . -mindepth 1); do
		DIRNAME=$(dirname "$PKGINSTALL/$FILE")
		if [ ! -e "$DIRNAME" ]; then
			mkdir -p "$DIRNAME"
		fi
	done

	#----------- construct package file list -----------------------------
	touch $PKGFILES/$PKGNAME
	for FILE in $(find . -mindepth 1); do
		if [ ! -d "$FILE" ]; then
			echo $FILE >> $PKGFILES/$PKGNAME
		fi
	done

	#---------------- fix prefix paths -----------------------------------
	# this breaks things pretty badly. needs a way to adjust path for
	# $PKGINSTALL, currently only works with /usr package installations
	# TODO can just add another global var if no good solutions $PKGADJUST
	#---------------------------------------------------------------------
	if [ -d "lib/pkgconfig" ]; then
		for FILE in $(find lib/pkgconfig -mindepth 1); do
			echo "-----------------------------------------------"
			echo "adjusting: $FILE"
			echo "-----------------------------------------------"
			sed -i "s|prefix=/.*|prefix=/usr|" $FILE
		done
	fi
	if [ -d "share/pkgconfig" ]; then
		for FILE in $(find share/pkgconfig -mindepth 1); do
			echo "-----------------------------------------------"
			echo "adjusting: $FILE"
			echo "-----------------------------------------------"
			sed -i "s|prefix=/.*|prefix=/usr|" $FILE
		done
	fi

	#----------- copy files to install destination  ----------------------
	for FILE in $(find . -mindepth 1 -type f); do
		cp -rv $FILE $PKGINSTALL/$FILE
	done

	#----------- copy symlinks to install destination  -------------------
	for FILE in $(find . -mindepth 1 -type l); do
		cp -rv $FILE $PKGINSTALL/$FILE
	done

	#-- TODO some way to chown, prompt for set caps, detect suid/gid bit --
	echo ""
	echo ""
	echo "$PKGNAME installed."
	echo ""
	touch $PKGDIR/$ITEM/.pkg-installed
	cd $PKGDIR
done

echo "installation complete"

