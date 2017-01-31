#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	#case pkgname*)
	#;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
