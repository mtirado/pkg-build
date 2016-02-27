#!/bin/bash
#PKGINSTALL="/podhome/local"
#PKGFILES="/podhome/local/.packages"
set -e
umask 022
#-----------------------------------------------------------------------------
if [ "$1" = "" ]; then
	echo "usage: pkg-remove name"
	exit -1
fi

if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi
PKGFILES="$PKGINSTALL/.packages"

echo "removing package from $PKGINSTALL"
echo "press any key to continue"
read -n 1 -s KEY
#-----------------------------------------------------------------------------
PKGNAME="$1"

#----------- check if package name is in use ---------------------------------
FIND=$(find $PKGFILES -name $PKGNAME)
if [ "$FIND" = "" ]; then
	echo "package $PKGNAME not found"
	exit -1
fi

#----------- TODO remove package directories if empty, otherwise error -------
#----------- user could either continue deleting, or quit and manually repair
#----------- we will need to update the package file to resume after repair!
#----------- remove files ----------------------------------------------------
cd $PKGINSTALL
while read FILE; do
	rm $PKGINSTALL/$FILE
done <$PKGFILES/$PKGNAME

#----------- remove package file ---------------------------------------------
rm $PKGFILES/$PKGNAME

echo "package $PKGNAME removed."

