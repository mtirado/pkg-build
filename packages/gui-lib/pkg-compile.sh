#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	pixman*)
		./configure 			\
		--prefix="$PKGPREFIX"		\
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
		--prefix="$PKGPREFIX"	\
		--disable-static	\
		--disable-intel		\
		--disable-radeon	\
		--disable-amdgpu	\
		--disable-nouveau	\
		--disable-vmwgfx
	;;
	SDL2*)
		./configure 			\
			--prefix="$PKGPREFIX"
			#--disable-static broken
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
