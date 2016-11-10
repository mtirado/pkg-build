#!/bin/sh
set -e
case "$PKGARCHIVE" in
#this needs cmake???
#x265*)
#	cd build/linux
#	ls -lah
#	./make-Makefiles.bash
#;;
gst-libav*)
	./configure 			\
		--prefix=/usr		\
		--disable-static-plugins
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
