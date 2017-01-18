#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	#case pkgname*)
	#;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS
make install
make_tar_prefix "$PKGROOT" /usr
