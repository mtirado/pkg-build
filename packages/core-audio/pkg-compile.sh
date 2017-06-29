#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	alsa-util*)
		./configure 			\
			--prefix="$PKGPREFIX"		\
			--disable-xmlto
	;;
	openal-*)
		# FIXME, this is installing to /usr/local
		cmake -G 'Unix Makefiles'
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
