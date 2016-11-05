#!/bin/sh
set -e
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

esac

#empty /usr
DESTDIR=$PKGROOT    \
	make install DESTDIR=$PKGROOT
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

