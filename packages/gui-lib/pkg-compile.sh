#!/bin/sh
set -e
case "$PKGARCHIVE" in

	*)
		./configure 			\
			--disable-static	\
			--prefix=/usr
	;;

esac

make -j$JOBS
DESTDIR=$PKGROOT 	\
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr
