#!/bin/sh
set -e

case "$PKGARCHIVE" in
	#case pkgname*)
	#;;
	*)
		./configure 			\
			--prefix=$PKGROOT
esac

make -j$JOBS
make install

