#!/bin/sh
set -e
case "$PKGARCHIVE" in
	man-pages*)
		sed -i "s|DESTDIR=|DESTDIR=$PKGROOT|" Makefile
		prefix=/usr	  \
			make
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
#empty /usr
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

