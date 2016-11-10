#!/bin/sh
set -e
case "$PKGARCHIVE" in
	gtk+-2*)
		./configure 			\
			--prefix=/usr		\
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
			--prefix=/usr		\
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
	*)
		./configure 			\
			--disable-static	\
			--prefix=/usr
	;;

esac

make -j$JOBS
DESTDIR=$PKGROOT 	\
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

case "$PKGARCHIVE" in
	gdk-pixbuf*)
		# fix loader info
		LD_LIBRARY_PATH=$PKGROOT/lib 						\
		GDK_PIXBUF_MODULEDIR=$PKGROOT/lib/gdk-pixbuf-2.0/2.10.0/loaders/	\
		$PKGROOT/bin/gdk-pixbuf-query-loaders > 				\
			$PKGROOT/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
		sed -i "s|$PKGROOT|/usr|" \
			$PKGROOT/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

	;;
esac