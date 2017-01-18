#!/bin/sh
set -e
source "$PKGINCLUDE"
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

case "$PKGARCHIVE" in
	gdk-pixbuf*)
		# fix loader info
		LD_LIBRARY_PATH=$PKGROOT/usr/lib                                       \
		GDK_PIXBUF_MODULEDIR=$PKGROOT/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/   \
		$PKGROOT/usr/bin/gdk-pixbuf-query-loaders >                            \
			$PKGROOT/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
		sed -i "s|$PKGROOT|/usr|" \
			$PKGROOT/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

	;;
esac
make_tar_prefix "$PKGROOT" /usr
