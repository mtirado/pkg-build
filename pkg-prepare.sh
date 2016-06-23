#!/bin/bash
set -e
umask 022
if [ "$1" = "" ]; then
	echo "usage: pkg-prepare <pkg-dir>"
	exit -1
fi

PKGDIR="$1"

if [ ! -f "$PKGDIR/wares" ]; then
	echo "missing package wares file"
	exit -1
fi

#-----------------------------------------------------------------------------
# download / extract packages
#-----------------------------------------------------------------------------
# TODO:
# download remote source packages. check sigs, checksums, filesize.
#-----------------------------------------------------------------------------
echo "acquiring and unpacking source archives..."
while read LINE; do
	PKGNAME=$(echo $LINE | cut -d " " -f 1)
	ARCHIVE=$(echo $LINE | cut -d " " -f 2)
	if [ ! -f "$PKGDIR/$ARCHIVE" ]; then
		echo "missing package archive $PKGDIR/$ARCHIVE"
		exit -1
	fi
	echo "tar xf $PKGDIR/$ARCHIVE"
	tar xfv $PKGDIR/$ARCHIVE
	mkdir -vp $PKGDISTDIR/$PKGNAME
done <$PKGDIR/wares
echo "done, ready for pkg-build"



