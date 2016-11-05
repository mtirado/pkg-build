#!/bin/sh
set -e
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

make -j$JOBS

case "$PKGARCHIVE" in
	alsa-util*)
		#alsactl store saves state here
		mkdir -p $PKGROOT/var/lib/alsa
	;;
esac
case "$PKGARCHIVE" in
	*)
		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;
esac

