#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	openal-*)

		cmake -G 'Unix Makefiles'		\
			-DCPACK_SET_DESTDIR="$PKGROOT"	\
			-DCMAKE_INSTALL_PREFIX="$PKGPREFIX"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
