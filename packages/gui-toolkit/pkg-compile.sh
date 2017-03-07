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
	mesa-demos*)
		./configure 			\
			--disable-static	\
			--without-glut		\
			--prefix="$PKGPREFIX"
	;;
	mesa-*)
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-dri			\
			--disable-driglx-direct		\
			--disable-dri3			\
			--disable-gbm			\
			--disable-egl			\
			--disable-drm			\
			--disable-gles1			\
			--disable-gles2			\
			--enable-glx=xlib		\
			--disable-llvm-shared-libs	\
			--disable-gallium-llvm		\
			--with-gallium-drivers=swrast
	;;
	SDL2*)
		./configure 			\
			--prefix="$PKGPREFIX"
			#--disable-static is/was broken
	;;
	glew-*)
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
