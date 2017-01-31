#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
#this needs cmake???
#x265*)
#	cd build/linux
#	ls -lah
#	./make-Makefiles.bash
#;;
gst-libav*)
	./configure 			\
		--prefix="$PKGPREFIX"	\
		--disable-static-plugins
;;
*)
	./configure 			\
		--prefix="$PKGPREFIX"
;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
