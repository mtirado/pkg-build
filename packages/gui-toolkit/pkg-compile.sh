#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	gtk+-2*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-static	\
			--disable-shm		\
			--disable-xinerama	\
			--disable-visibility	\
			--disable-cups		\
			--disable-papi
			#
			#--disable-modules	\
			# hrm?
			#--enable-xkb		\
			#--without-x

	;;
	gtk+-3*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-static	\
			--disable-static	\
			--disable-shm		\
			--disable-xinerama	\
			--disable-visibility	\
			--disable-cups		\
			--disable-papi		\
			--disable-cloud-print	\
			--enable-xkb

	;;
	*)
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
