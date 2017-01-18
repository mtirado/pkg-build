#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	gtk+-2*)
		./configure 			\
			--prefix=/usr		\
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
			--prefix=/usr		\
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
			--prefix=/usr
	;;

esac

make -j$JOBS
DESTDIR=$PKGROOT make install
make_tar_prefix "$PKGROOT" /usr
