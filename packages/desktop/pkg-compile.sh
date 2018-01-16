#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	xlunch*)

		# save this package for the end of the build, it will read
		# .desktop files in /usr/share/applications to generate
		# the icon launchers automatically

		# adjust conf file location, and fix some warnings
		#sed -i "s#\"/etc/xlunch#\"$PKGPREFIX/etc/xlunch#" xlunch.c
		#sed -i "s#Pixmap currentRootPixmap;#Pixmap currentRootPixmap = None;#" xlunch.c
		#sed -i "s#int cleanup()#void cleanup()#" xlunch.c

		# include a modified genconf
		cp -vf "$_PKG_DIR/genconf" ./extra/genconf

		export CFLAGS="-O1 -s -pedantic -Wall -Wextra"
		make
		# older version might have needed this.
		#mkdir -vp "$PKGROOT/$PKGPREFIX/etc/xlunch"
		#mkdir -vp "$PKGROOT/$PKGPREFIX/share/xlunch"
		#mkdir -vp "$PKGROOT/$PKGPREFIX/bin"
		#cp -v  ./icons.conf "$PKGROOT/$PKGPREFIX/etc/xlunch"
		#cp -v  ./xlunch "$PKGROOT/$PKGPREFIX/bin"
		#cp -vr ./extra "$PKGROOT/$PKGPREFIX/share/xlunch"
		mkdir -vp "$PKGROOT/$PKGPREFIX/bin"
		cp -v ./extra/genconf "$PKGROOT/$PKGPREFIX/bin/xlunch-genconf"
		chmod -v +x "$PKGROOT/$PKGPREFIX/bin/xlunch-genconf"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;

esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
	xfe*)
		#setup default progs for xfe
		echo "" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "# default helpers" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "[PROGS]" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "pdfviewer=mupdf-x11" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "imgviewer=xfi" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "videoplayer=gmplayer" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "audioplayer=gmplayer" >> "$PKGROOT/usr/share/xfe/xferc"
		echo "imageditor=gimp-2.9" >> "$PKGROOT/usr/share/xfe/xferc"
	;;
esac
make_tar_flatten_subdirs "$PKGROOT"
