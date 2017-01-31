#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	gnupg-*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-agent		\
			--disable-scdaemon	\
			--enable-gpgtar
		sed -i 's|tests.*=.*tests|tests = |' Makefile

	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
