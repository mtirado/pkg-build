#!/bin/sh
set -e
case "$PKGARCHIVE" in
	pixman*)
		./configure 			\
		--prefix=/usr			\
		--disable-static		\
		--disable-openmp		\
		--disable-longsoon-mmi		\
		--disable-arm-simd		\
		--disable-arm-neon		\
		--disable-arm-iwmmxt		\
		--disable-arm-iwmmxt2		\
		--disable-mips-dspr2		\
		--disable-gtk			\
		--disable-libpng		\
		--disable-timers
	;;
	libdrm*)
		./configure 		\
		--prefix=/usr		\
		--disable-static	\
		--disable-intel		\
		--disable-radeon	\
		--disable-amdgpu	\
		--disable-nouveau	\
		--disable-vmwgfx
	;;
	SDL2*)
		./configure 			\
			--prefix=/usr
			#--disable-static broken
	;;
	*)
		./configure 			\
			--disable-static	\
			--prefix=/usr
	;;

esac

make -j$JOBS
DESTDIR=$PKGROOT 	\
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr
