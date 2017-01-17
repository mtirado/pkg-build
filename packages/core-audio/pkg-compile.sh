#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	alsa-util*)
		./configure 			\
			--prefix=/usr		\
			--disable-xmlto
	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make "-j$JOBS"

case "$PKGARCHIVE" in
	alsa-util*)
		#alsactl store saves state here
		mkdir -p "$PKGROOT/var/lib/alsa"
	;;
esac

DESTDIR=$PKGROOT    \
	make install
make_tar_prefix "$PKGROOT" /usr
