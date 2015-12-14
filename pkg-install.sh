#!/bin/bash
umask 022
set -e
#-----------------------------------------------------------------------------
#src-dir should be the source directory where configure is located
if [ "$1" = "" ]; then
	echo "usage: pkg-install <pkg-dir> name"
	exit -1
fi
if [ "$2" = "" ]; then
	echo "usage: pkg-install <pkg-dir> name"
	exit -1
fi

#-----------------------------------------------------------------------------

NEWPKG="$1"
PKGFILES="/podhome/local/.packages"
INSTALL="/podhome/local"
PKGNAME="$2"
CD=$(pwd)

echo ""

#---------- create pkgs directory if needed ----------------------------------
if [ ! -d "$PKGFILES" ]; then
	mkdir $PKGFILES
fi


#----------- check if package name is in use ---------------------------------
FIND=$(find $PKGFILES -name $PKGNAME)
if [ "$FIND" != "" ]; then
	echo "package $PKGNAME already exists, run pkg-remove first."
	exit -1
else
	echo "will create new package at $PKGFILES/$PKGNAME"
fi


#----------- fail if file exists ---------------------------------------------
cd $NEWPKG
find . -print0 | while IFS= read -r -d '' FILE
do
	# ignore directories
	if [ ! -d "$FILE" ]; then
		if [ -e "$INSTALL/$FILE" ]; then
			echo "error, $INSTALL/$FILE already exists"
			echo "run pkg-remove or manually clean up?"
			exit -1
		fi
	fi
done


#----------- construct package file list -------------------------------------
touch $PKGFILES/$PKGNAME
find . -print0 | while IFS= read -r -d '' FILE; do
	if [ ! -d "$FILE" ]; then
		echo "$FILE" >> $PKGFILES/$PKGNAME
	fi
done
cd $CD
pwd
echo "newpkg: $NEWPKG"
cd $NEWPKG
#----------- construct package file list -------------------------------------
for FILE in *; do
	echo "cp $FILE"
	cp -rv "$FILE" $INSTALL/
done
#cp -rv $NEWPKG/\* $INSTALL/ > $PKGFILES/$PKGNAME.log












