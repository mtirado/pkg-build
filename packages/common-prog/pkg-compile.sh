#!/bin/sh
set -e
case "$PKGARCHIVE" in
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS

DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

