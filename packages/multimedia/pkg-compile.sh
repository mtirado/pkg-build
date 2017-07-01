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
		--disable-shm		\
		--enable-relocatable
	# gmplayer fails if sysv ipc is disabled in kernel
	mkdir -pv "$PKGROOT/usr/etc"

	# setup default conf, gmplayer doesn't like to open -vo x11, which is much
	# better than trying to use opengl on software implementation
	echo "vo=x11" > "$PKGROOT/usr/etc/mplayer.conf"

;;
xmmplayer*|hwswskin*)
	#mplayer skins
	echo "PKGDISTNAME=$PKGDISTNAME"
	mkdir -pv "$PKGROOT/share/mplayer/skins/$PKGDISTNAME/"
	cp -av ./* "$PKGROOT/share/mplayer/skins/$PKGDISTNAME/"
	case "$PKGARCHIVE" in
		# use hwswskin as default
		hwswskin*)
			mkdir -pv "$PKGROOT/share/mplayer/skins/default/"
			cp -av ./* "$PKGROOT/share/mplayer/skins/default/"
			;;
	esac
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
	cmake -G 'Unix Makefiles'		\
		-DCPACK_SET_DESTDIR="$PKGROOT"	\
		-DCMAKE_INSTALL_PREFIX="$PKGPREFIX"
;;
*)
	./configure 			\
		--prefix="$PKGPREFIX"
;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
