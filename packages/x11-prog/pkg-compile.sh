#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	xterm*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--without-xinerama	\
			--without-Xaw3d		\
			--without-Xaw3dxft	\
			--without-neXtaw	\
			--without-XawPlus	\
			--disable-setuid	\
			--disable-setgid	\
			--enable-256-color	\
			--disable-paste64
			#--disable-freetype
			#--with-own-terminfo=
		sed -i "s|DESTDIR.*=.*|DESTDIR = $PKGROOT|" Makefile
	;;
	icewm-1*)
		# what's this do? other than cause build error
		sed -i "s/icesh\ //" configure
		./configure 			\
			--prefix="$PKGROOT/$PKGPREFIX"	\
			--disable-i18n			\
			--disable-nls			\
			--disable-sm			\
			--disable-xrandr		\
			--disable-xinerama
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
