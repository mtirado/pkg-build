#!/bin/bash
#PKGINSTALL="/podhome/local"
#PKGFILES="/podhome/local/.packages"
PKGINSTALL="/usr/local"
PKGFILES="/usr/local/.packages"
umask 022
set -e
#-----------------------------------------------------------------------------
# pkgbuild-dir is the distribution folder normally set by ./configure --prefix
# which is populated on make install
if [ "$1" = "" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkgname>"
	exit -1
fi
if [ "$2" = "" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkgname>"
	exit -1
fi

#-----------------------------------------------------------------------------

PKGDIR="$1"
PKGNAME="$2"
DISTDIR="$PKGDIR"
CWD=$(pwd)

#---------- create pkgs directory if needed ----------------------------------
if [ ! -d "$PKGFILES" ]; then
	mkdir $PKGFILES
fi


#----------- check if package name is in use ---------------------------------
FIND=$(find $PKGFILES -name $PKGNAME)
if [ "$FIND" != "" ]; then
	echo "package $PKGNAME already exists, run pkg-remove first."
	exit -1
fi


#----------- fail if file exists ---------------------------------------------
cd $DISTDIR
EXISTS=0
find . -print0 | (
	while IFS= read -r -d '' FILE
	do
		# ignore directories
		if [ ! -d "$FILE" ]; then
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "$PKGINSTALL/$FILE already exists"
				EXISTS=$((EXISTS + 1))
			fi
		fi
	done
	if [ "$EXISTS" != "0" ]; then
		echo "error: $EXISTS file(s) already exist in $PKGINSTALL"
		# we could scan packages to find which one owns file
		exit -1
	fi
)
#----------- TODO strip debug info -------------------------------------------
# optional of course...

#----------- construct package file list -------------------------------------
touch $PKGFILES/$PKGNAME
find . -print0 | while IFS= read -r -d '' FILE; do
	if [ ! -d "$FILE" ]; then
		echo "$FILE" >> $PKGFILES/$PKGNAME
	fi
done
cd $CWD
cd $DISTDIR
#----------- copy files to install destination  ------------------------------
for FILE in *; do
	cp -r "$FILE" $PKGINSTALL/
done












