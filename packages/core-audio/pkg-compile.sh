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

make "-j$JOBS"

case "$PKGARCHIVE" in
	alsa-util*)
		#alsactl store saves state here
		mkdir -p "$PKGROOT/var/lib/alsa"
	;;
esac

DESTDIR=$PKGROOT    \
	make install
# TODO add support for arbitrary prefixes
cd "$PKGROOT/usr"
tar -cf "$PKGROOT/usr.tar" ./*
cd ..
rm -rf ./usr


