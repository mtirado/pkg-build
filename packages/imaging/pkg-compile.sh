#!/bin/sh
set -e
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
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

