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
	URI*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		perl Makefile.PL PREFIX="$PKGROOT/$PKGPREFIX" INSTALLDIRS=perl
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
