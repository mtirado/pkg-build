#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	setuptools*)
		mkdir -p "$PKGROOT/lib/python2.7/site-packages"
		PYTHONPATH="$PKGROOT/lib/python2.7/site-packages/"	\
			python setup.py install --prefix="$PKGROOT"
		exit 0
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
