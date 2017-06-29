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
	fontconfig*)
		patch -s -p1 < "$_PKG_DIR/0001-Avoid-conflicts-with-integer-width-macros-from-TS-18.patch"
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;
	icu*)
		cd source
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;
	graphite*)
		cmake -G 'Unix Makefiles' 		\
			-DCPACK_SET_DESTDIR="$PKGROOT"	\
			-DCMAKE_INSTALL_PREFIX="$PKGPREFIX"
	;;
	*)
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
make DESTDIR="$PKGROOT" install
make_tar_flatten_subdirs "$PKGROOT"
