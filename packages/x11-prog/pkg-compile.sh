#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	#case pkgname*)
	#;;
	xterm*)
		./configure 			\
			--prefix=/usr		\
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
		sed -i "s|DESTDIR.*=.*|DESTDIR = $PKGROOT/$PKGPREFIX|" Makefile
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
