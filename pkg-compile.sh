#!/bin/sh
set -e
case "$PKGARCHIVE" in
	#case pkgname*)
	#;;
	*)
		./configure 			\
			--prefix=/usr
esac

#empty /usr
DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

