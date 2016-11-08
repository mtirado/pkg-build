#!/bin/sh
set -e
case "$PKGARCHIVE" in
	xpdf*)
		mkdir -p $PKGROOT/usr
		./configure 			\
			--prefix=$PKGROOT/usr
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS

DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

