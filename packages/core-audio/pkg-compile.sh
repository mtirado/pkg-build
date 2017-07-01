#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	alsa-util*)
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-xmlto
	;;
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

case "$PKGARCHIVE" in
	alsa-util*)
		#alsactl store saves state here
		mkdir -p "$PKGROOT/var/lib/alsa"
	;;
esac

DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
