#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in

	gdk-pixbuf*)
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"	\
			--without-gdiplus	\
			--without-libtiff
	;;
	*)
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
	gdk-pixbuf*)
		PFXDEST="$PKGROOT/$PKGPREFIX"
		# fix loader info
		LD_LIBRARY_PATH="$PFXDEST/lib"                                     \
		GDK_PIXBUF_MODULEDIR=$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders/   \
		"$PFXDEST/bin/gdk-pixbuf-query-loaders" >                          \
			"$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
		sed -i "s|$PKGROOT|/$PKGPREFIX|" \
			"$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"

	;;
esac
make_tar_flatten_subdirs "$PKGROOT"
