#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
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
FFmpeg*)
	./configure 			\
		--prefix="$PKGPREFIX"	\
		--enable-extra-warnings	\
		--enable-shared		\
		--disable-swscale-alpha
#--enable-pic
;;
MPlayer*)
	./configure 			\
		--prefix="$PKGPREFIX"	\
		--enable-gui		\
		--enable-relocatable

;;
xmmplayer*|hwswskin*)
	#mplayer skins
	mkdir -pv "$PKGROOT/share/mplayer/skins/$PKGDISTNAME/"
	cp -av ./* "$PKGROOT/share/mplayer/skins/$PKGDISTNAME/"
	make_tar "$PKGROOT"
	exit 0
;;
vlc*)
	./configure 			\
		--prefix="$PKGPREFIX"	\
		--disable-lua		\
		--disable-mad
;;
qt-gstream*)
	cmake -G 'Unix Makefiles'
;;
*)
	./configure 			\
		--prefix="$PKGPREFIX"
;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
