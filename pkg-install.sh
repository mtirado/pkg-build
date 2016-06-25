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
PKGNAME="$2"
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
for ITEM in `find . -mindepth 1 -maxdepth 1`; do
	EXISTS=0
	EXCEPT=0
	PKGNAME=$ITEM

	#----------- check if package name is in use -------------------------
	FIND=$(find $PKGFILES -print -mindepth 1 -maxdepth 1 -name $PKGNAME)
	if [ "$FIND" != "" ]; then
		echo "-----------------------------------------------------------------"
		echo " package already exists, did you forget to run pkg-remove ?"
		echo " skip installing package $PKGNAME ? (y/n)"
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
	for FILE in `find . -mindepth 1`; do
		if [ ! -d "$FILE" ]; then
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "$PKGINSTALL/$FILE already exists"
				EXISTS=$((EXISTS + 1))
				EXCEPT=1
			elif [ "$EXCEPT" = "0" ]; then
				MKPATH=$(dirname "$PKGINSTALL/$FILE")
				if [ ! -e "$MKPATH" ]; then
					echo "make path: $MKPATH"
					mkdir -vp "$MKPATH"
				fi
			fi
		else
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "make path: $PKGINSTALL/$FILE"
				mkdir -p "$PKGINSTALL/$FILE"
			fi
		fi
	done

	if [ "$EXISTS" != "0" ]; then
		# TODO check used files in another pass before creating dirs
		# TODO we should scan packages to find which one owns file
		echo "-----------------------------------------------------------------"
		echo "error: $EXISTS file(s) already exist in $PKGINSTALL"
		echo  "skip installing package $PKGNAME ? (y/n)"
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


	#----------- construct package file list -----------------------------
	touch $PKGFILES/$PKGNAME
	for FILE in `find . -mindepth 1`; do
		if [ ! -d "$FILE" ]; then
			echo $FILE >> $PKGFILES/$PKGNAME
		fi
	done

	#----------- copy files to install destination  ----------------------
	for FILE in `find . -type f -mindepth 1`; do
		cp -rv $FILE $PKGINSTALL/$FILE
	done

	#----------- copy symlinks to install destination  -------------------
	for FILE in `find . -type l -mindepth 1`; do
		cp -rv $FILE $PKGINSTALL/$FILE
	done

	#----------- fix pkg-config prefix -----------------------------------
	for FILE in `find lib/pkgconfig -mindepth 1`; do
		echo "-----------------------------------------------"
		echo "adjusting: $FILE"
		echo "-----------------------------------------------"
		sed "s|prefix=/.*|prefix=/usr/lib|" $FILE
	done

	#-- TODO some way to chown, prompt for set caps, suid/gid bit, etc --

	cd $DISTDIR
done



