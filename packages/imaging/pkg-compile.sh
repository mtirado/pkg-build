#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	cups-*)
		JOBS=1
		# might need this if kerberos is not installed
		#sed -i '/kerberized/,$ d' conf/cupsd.conf.in
		aclocal  -I config-scripts
		autoconf -I config-scripts
		./configure 					\
			--prefix="$PKGROOT/usr"			\
			--with-rcdir="/tmp/cupsjunk$$"		\
			--with-menudir="/tmp/cupsjunk$$"	\
			--with-icondir="/tmp/cupsjunk$$"	\
			--disable-systemd			\
			--disable-unit-tests
		# make config file?
		#echo "ServerName /var/run/cups/cups.sock" > <usr?>/etc/cups/client.conf
	;;

	aalib*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		./configure 				\
			--prefix="$PKGROOT/$PKGPREFIX"	\
	;;
	librsvg*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-introspection
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

# prune mupdf, instead of static linked blimp by default (over 100MB .xz)
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
