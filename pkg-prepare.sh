#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#-----------------------------------------------------------------------------
set -e
if [ "$1" = "" ]; then
	echo "usage: pkg-prepare <pkg-dir>"
	exit -1
fi

PKGDIR="$1"

if [ ! -f "$PKGDIR/wares" ]; then
	echo "missing package wares file"
	exit -1
fi
if [ -z "$PKGPASS" ]; then
	echo "error, PKGPASS is not set"
	exit -1
fi

#-----------------------------------------------------------------------------
# download / extract packages
#-----------------------------------------------------------------------------
# TODO:
# download remote source packages. check sigs, checksums, filesize.
#-----------------------------------------------------------------------------
while read LINE; do
	PKGNAME=$(echo $LINE | cut -d " " -f 2)
	ARCHIVE=$(echo $LINE | cut -d " " -f 3)
	ARCHIVEDIR=${ARCHIVE%.tar.*}

	#skip extraction if build directory exists and is marked as built
	if [ -e "$PKGBUILDDIR/$ARCHIVEDIR" ]; then
		#if [ -e "$PKGBUILDDIR/$ARCHIVEDIR/.pkg-built" ]; then
			continue
		#else
			#echo "build is incomplete, remove source dir and try again."
			#echo "source dir: $PKGBUILDDIR/$ARCHIVEDIR"
			#echo "or complete the build manually and run"
			#echo "touch $PKGBUILDDIR/$ARCHIVEDIR/.pkg-built"
			#exit -1
		#fi
	fi

	if [ ! -f "$PKGDIR/$ARCHIVE" ]; then
		echo "missing package archive $PKGDIR/$ARCHIVE"
		exit -1
	fi
	echo "extracting $ARCHIVE"
	tar xf $PKGDIR/$ARCHIVE
done <$PKGDIR/wares

#filter for current pass
cp "$PKGDIR/wares" "$PKGBUILDDIR/multipass"
cp "$PKGDIR/wares" "$PKGBUILDDIR/wares"
sed -i "/^[^$PKGPASS]/d" "$PKGBUILDDIR/wares"
if [ ! -s "$PKGBUILDDIR/wares" ]; then
	echo "pass is empty, build complete"
	exit 1
fi

# create distribution dirs for current pass
#while read LINE; do
#	PKGNAME=$(echo $LINE | cut -d " " -f 2)
#	mkdir -vp $PKGDISTDIR/$PKGNAME
#done <$PKGBUILDDIR/wares


