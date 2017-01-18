#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	gnupg-*)
		./configure 			\
			--prefix=/usr		\
			--disable-agent		\
			--disable-scdaemon	\
			--enable-gpgtar
		sed -i 's|tests.*=.*tests|tests = |' Makefile

	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
DESTDIR=$PKGROOT make install
make_tar_prefix "$PKGROOT" /usr
