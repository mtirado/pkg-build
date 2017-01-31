#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	man-pages*)
		sed -i "s|DESTDIR=|DESTDIR=$PKGROOT|" Makefile
		prefix="$PKGPREFIX" make
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"

