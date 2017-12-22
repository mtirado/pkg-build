#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
# TODO detect failure during decompression don't try to build
# partially decompressed packages!
##-----------------------------------------------------------------------------
set -e
if [ "$1" = "" ]; then
	echo "usage: pkg-prepare <pkg-dir>"
	exit -1
fi

_PKG_DIR="$1"

if [ ! -f "$_PKG_DIR/wares" ]; then
	echo "missing package wares file"
	exit -1
fi
if [ -z "$PKGPASS" ]; then
	echo "error, PKGPASS is not set"
	exit -1
fi

# this doesn't have any effect unless build scripts implement it.
# there are a few specific packages that trigger:  make[2]: write error: stdout
# this eases the pain of recompiling the large packages gcc,browsers,etc
# by allowing scripts to re-enter make without overwriting configuration.
#
# if using this you will probably need to make numerous retries before success =(
#
# NOTE: for this to work troublesome packages need to implement the check
#       this echo notice is mainly for documentation purposes
#	problems seen on i686 \usually\ with parallel builds.
#       if anyone out there figures out wtf causes this, send me a line.
if [ "$PKGNOCONF" != "" ]; then
	echo "PKGNOCONF IS SET"
fi
#-----------------------------------------------------------------------------
# download / extract packages
#-----------------------------------------------------------------------------
# TODO:
# download remote source packages. check sigs, checksums, filesize.
#-----------------------------------------------------------------------------
while read LINE; do
	PASS=$(echo $LINE | cut -d " " -f 1)
	if [ "$PASS" = "0" ]; then
		continue
	fi
	PKGNAME=$(echo $LINE | cut -d " " -f 2)
	ARCHIVE=$(echo $LINE | cut -d " " -f 3)
	PKGARCHIVE=${ARCHIVE%.tar.*}
	PKGARCHIVE=$(basename $PKGARCHIVE)
	#skip extraction if build directory exists
	if [ -e "$PKGBUILDDIR/$PKGARCHIVE" ] || [ "$PASS" = "0" ]; then
		continue
	fi

	if [ ! -f "$_PKG_DIR/$ARCHIVE" ]; then
		echo "missing package archive $_PKG_DIR/$ARCHIVE"
		exit -1
	fi
	echo "extracting $ARCHIVE"
	rm -rf "$PKGBUILDDIR/pkgdist/$PKGNAME"
	tar xf "$_PKG_DIR/$ARCHIVE"
done < "$_PKG_DIR/wares"

#filter for current pass
cp "$_PKG_DIR/wares" "$PKGBUILDDIR/multipass"
cp "$_PKG_DIR/wares" "$PKGBUILDDIR/wares"
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


