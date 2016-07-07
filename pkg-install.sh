#!/bin/bash
#PKGINSTALL - destination
umask 022
set -e
#-----------------------------------------------------------------------------
if [ "$1" = "" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-install <pkgdist-dir>"
	echo "set PKGINSTALL="/new/path" to install to other directories"
	exit -1
fi

if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi


#-----------------------------------------------------------------------------
PKGFILES="$PKGINSTALL/.packages"
PKGDIR="$1"
PKGNAME="?????"
DISTDIR="$PKGDIR"
CWD=$(pwd)

echo "installing package $PKGDIR to $PKGINSTALL"
echo "press any key to continue"
read -n 1 -s KEY

#---------- create pkgs directory if needed --------------------------
if [ ! -d "$PKGFILES" ]; then
	mkdir $PKGFILES
fi

cd $DISTDIR
for ITEM in $(find . -mindepth 1 -maxdepth 1 -printf '%f\n'); do
	EXISTS=0
	PKGNAME=$ITEM
	echo "PKGNAME $PKGNAME"
	#----------- check if package name is in use -------------------------
	FIND=$(find $PKGFILES -mindepth 1 -maxdepth 1 -name "$PKGNAME" -printf '%f\n')
	if [ "$FIND" != "" ]; then
		echo "-----------------------------------------------------------------"
		echo " package already exists, did you forget to run pkg-remove ?"
		echo " skip installing $PKGNAME ? (y/n)"
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
	cd $DISTDIR/$ITEM

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
		echo "-----------------------------------------------------------------"
		echo "$PKGNAME: $EXISTS file(s) already exist in $PKGINSTALL"
		echo "you have 3 possible actions"
		echo "(s)kip, (o)verwrite (this is currently dangerous if file"
		echo "is being used by another package since we do not scan yet),"
		echo "or press any other key to quit installation"
		echo "-----------------------------------------------------------------"
		read -n 1 -s ACK
		if [ "$ACK" == "s" ] || [ "$ACK" == "S" ]; then
			continue
		elif [ "$ACK" != "o" ] && [ "$ACK" != "O" ]; then
			echo "installation failed."
			exit -1
		fi
	fi

	#----------- create directories --------------------------------------
	echo "creating directories..."
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

	#----------- copy files to install destination  ----------------------
	for FILE in $(find . -type f -mindepth 1); do
		cp -rv $FILE $PKGINSTALL/$FILE
	done

	#----------- copy symlinks to install destination  -------------------
	for FILE in $(find . -type l -mindepth 1); do
		cp -rv $FILE $PKGINSTALL/$FILE
	done


	#---------------- fix pkg-config prefix ------------------------------
	if [ -d "lib/pkgconfig" ]; then
		for FILE in $(find lib/pkgconfig -mindepth 1); do
			echo "-----------------------------------------------"
			echo "adjusting: $FILE"
			echo "-----------------------------------------------"
			sed "s|prefix=/.*|prefix=/usr/lib|" $FILE
		done
	fi
	#-- TODO some way to chown, prompt for set caps, detect suid/gid bit --
	echo ""
	echo ""
	echo "$PKGNAME installed."
	echo ""
	cd $DISTDIR
done

echo "installation complete"

