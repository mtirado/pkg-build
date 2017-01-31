#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	aalib*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		./configure 				\
			--prefix="$PKGROOT/$PKGPREFIX"	\
	;;
	librsvg*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--enable-introspection=no
	;;
	gimp*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-glibtest	\
			--disable-gtktest	\
			--disable-python
	;;
	gegl*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-glibtest	\
			--disable-nls
	;;
	libmypaint*)
		./autogen.sh
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	xpdf*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		./configure 						 	 \
			--prefix="$PKGROOT/$PKGPREFIX"				 \
			--with-x						 \
			--with-freetype2-library="$PKGPREFIX/lib/libfreetype.so" \
			--with-freetype2-includes="$PKGPREFIX/include/freetype2"
	;;
	mupdf*)
		sed -i "s|HAVE_GLFW.*=.*|HAVE_GLFW=no|" Makethird
		sed -i "s|prefix.*?=.*|prefix=$PKGPREFIX|" Makefile
		make HAVE_GLFW=no "-j$JOBS"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install

# XXX mupdf-lite, instead of static linked blimp by default (over 100MB .xz)
# is there a disable static option?
case "$PKGARCHIVE" in
	mupdf*)
		rm -r "$PKGROOT/$PKGPREFIX/include"
		rm -r "$PKGROOT/$PKGPREFIX/lib"
		rm    "$PKGROOT/$PKGPREFIX/bin/muraster"
		rm    "$PKGROOT/$PKGPREFIX/bin/mujstest"
		rm    "$PKGROOT/$PKGPREFIX/bin/mupdf-x11-curl"
	;;
esac
make_tar_flatten_subdirs "$PKGROOT"
