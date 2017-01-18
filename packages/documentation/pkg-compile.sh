#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	man-pages*)
		sed -i "s|DESTDIR=|DESTDIR=$PKGROOT|" Makefile
		prefix=/usr make
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
make_tar_prefix "$PKGROOT" /usr

