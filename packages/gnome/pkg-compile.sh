#!/bin/sh
set -e
case "$PKGARCHIVE" in

	gdk-pixbuf*)
		./configure 			\
			--disable-static	\
			--prefix=/usr		\
			--without-gdiplus	\
			--without-libtiff
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
