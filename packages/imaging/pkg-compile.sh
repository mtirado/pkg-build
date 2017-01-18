#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	aalib*)
		mkdir -p $PKGROOT/usr
		./configure 			\
			--prefix=$PKGROOT/usr	\
	;;
	librsvg*)
		./configure 			\
			--prefix=/usr		\
			--enable-introspection=no
	;;
	gimp*)
		./configure 			\
			--prefix=/usr		\
			--disable-glibtest	\
			--disable-gtktest	\
			--disable-python
	;;
	gegl*)
		./configure 			\
			--prefix=/usr		\
			--disable-glibtest	\
			--disable-nls
	;;
	libmypaint*)
		./autogen.sh
		./configure 			\
			--prefix=/usr
	;;
	xpdf*)
		mkdir -p $PKGROOT/usr
		./configure 						 \
			--prefix=$PKGROOT/usr				 \
			--with-x					 \
			--with-freetype2-library=/usr/lib/libfreetype.so \
			--with-freetype2-includes=/usr/include/freetype2
	;;
	mupdf*)
		sed -i 's|HAVE_GLFW.*=.*|HAVE_GLFW=no|' Makethird
		sed -i 's|prefix.*?=.*|prefix=/usr|' Makefile
		make HAVE_GLFW=no -j$JOBS
	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
DESTDIR=$PKGROOT make install

# XXX mupdf-lite, instead of static linked blimp by default (over 100MB .xz)
case "$PKGARCHIVE" in
	mupdf*)
		rm -r $PKGROOT/usr/include
		rm -r $PKGROOT/usr/lib
		rm $PKGROOT/usr/bin/muraster
		rm $PKGROOT/usr/bin/mujstest
		rm $PKGROOT/usr/bin/mupdf-x11-curl
	;;
esac
make_tar_prefix "$PKGROOT" /usr
