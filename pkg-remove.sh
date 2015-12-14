#!/bin/bash
set -e
#-----------------------------------------------------------------------------
#src-dir should be the source directory where configure is located
if [ "$1" = "" ]; then
	echo "usage: pkg-remove name"
	exit -1
fi


#-----------------------------------------------------------------------------
PKGFILES="/podhome/local/.packages"
INSTALL="/podhome/local"
PKGNAME="$1"


#----------- check if package name is in use ---------------------------------
FIND=$(find $PKGFILES -name $PKGNAME)
if [ "$FIND" = "" ]; then
	echo "package $PKGNAME not found"
	exit -1
fi

echo "removing files"
#----------- remove files ----------------------------------------------------
cd $INSTALL
while read FILE; do
	rm $FILE
done <$PKGFILES/$PKGNAME

echo "removing package file"
#----------- remove package file ---------------------------------------------
rm $PKGFILES/$PKGNAME

echo "package $PKGNAME removed."

