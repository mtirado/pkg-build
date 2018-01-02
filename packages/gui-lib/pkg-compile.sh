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
		#sed -i 's/test -z "$ITSTOOL"/test -z "notz"/' configure.ac
		#autoreconf
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"	\
			--disable-docs
	;;
	icu*)
		cd "./source"
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;
	graphite*)
		cmake -G 'Unix Makefiles' 		\
			-DCPACK_SET_DESTDIR="$PKGROOT"	\
			-DCMAKE_INSTALL_PREFIX="$PKGPREFIX"
	;;
	intltool*)
		# wow this is annoying
		patch -s -p1 < "$_PKG_DIR/perl-5.22-compatibility.patch"
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
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
