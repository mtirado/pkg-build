#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	gdk-pixbuf*)
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"	\
			--without-gdiplus	\
			--without-libtiff	\
			--enable-gio-sniffing=no
			#--with-x11		\
	;;
	gtk+-2*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
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
	# why is this mandatory for gtk3 ? :\
	libepoxy*)
		./configure			\
			--prefix="$PKGPREFIX"	\
			--enable-egl=no
	;;
	gtk+-3*)
		#./autogen.sh 			\
		#./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-static	\
			--disable-shm		\
			--disable-xinerama	\
			--disable-visibility	\
			--disable-papi		\
			--disable-cloud-print	\
			--enable-xkb
			#--disable-cups		\
	;;
	gobj*)
		./autogen.sh			\
			--prefix="$PKGPREFIX"
	;;
	mesa-demos*)
		./configure 			\
			--disable-static	\
			--without-glut		\
			--prefix="$PKGPREFIX"
	;;
	mesa-*)
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-dri			\
			--disable-driglx-direct		\
			--disable-dri3			\
			--disable-gbm			\
			--disable-egl			\
			--disable-drm			\
			--disable-gles1			\
			--disable-gles2			\
			--enable-glx=xlib		\
			--disable-llvm-shared-libs	\
			--disable-gallium-llvm		\
			--with-gallium-drivers=swrast
	;;
	SDL2*)
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-video-opengl		\
			--disable-video-opengles	\
			--disable-video-opengles1	\
			--disable-video-opengles2
			#--disable-static is/was broken
	;;
	glew-*)
	;;
	qt-everywhere*)
		export COMMERCIAL_USER="no"
		export QTROOT="$PWD"
		case "$PKGDISTNAME" in
		qt5)
			export QMAKE="$QTROOT/qtbase/bin/qmake"
			cd qtbase
			./configure 				\
				-prefix "$PKGPREFIX"		\
				-opensource 			\
				-confirm-license		\
				-release			\
				-no-reduce-relocations		\
				-no-pch				\
				-no-qml-debug			\
				-nomake tests 			\
				-nomake examples		\
				-no-dbus 			\
				-no-openssl 			\
				-no-accessibility 		\
				-no-glib 			\
				-no-opengl
			make "-j$JOBS"
		;;
		qt5multimedia)
			cd qtmultimedia
			qmake -o Makefile "$QTROOT/qtmultimedia/qtmultimedia.pro" \
					-qtconf "$QTROOT/qtbase/bin/qt.conf"
			make "-j$JOBS"
		;;
		qt5svg)
			cd qtsvg
			qmake -o Makefile "$QTROOT/qtsvg/qtsvg.pro" \
					-qtconf "$QTROOT/qtbase/bin/qt.conf"
			make "-j$JOBS"
		;;
		qt5declarative)
			cd qtdeclarative
			qmake -o Makefile "$QTROOT/qtdeclarative/qtdeclarative.pro" \
					-qtconf "$QTROOT/qtbase/bin/qt.conf"
			make "-j$JOBS"
		;;
		qt5webchannel)
			cd qtwebchannel
			qmake -o Makefile "$QTROOT/qtwebchannel/qtwebchannel.pro" \
					-qtconf "$QTROOT/qtbase/bin/qt.conf"
			make "-j$JOBS"
		;;
		qt5webengine)
			cd qtwebengine
			qmake -o Makefile "$QTROOT/qtwebengine/qtwebengine.pro"
					#-qtconf "$QTROOT/qtbase/bin/qt.conf"
			export CPATH=/usr/include/QtNetwork:/usr/include/QtQuick:/usr/include/QtQuick/5.9.0:/usr/include/QtQuick/5.9.0/QtQuick:/usr/include/QtQml/5.9.0
			export LD_LIBRARY_PATH=/usr/lib
			make "-j$JOBS"
		;;
		*)
			echo "unknown qt package"
			exit -1
		;;
		esac

		echo "installing $PKGROOT"
		# seeing an odd nonzero exit status, look the other way and try again
		set +e
			make INSTALL_ROOT="$PKGROOT" install
		set -e
		if [ $? -ne 0 ]; then
			echo ""
			echo " ! first make install returned non-zero: $? !"
			echo ""
			make INSTALL_ROOT="$PKGROOT" install
		fi
		echo "tarring $PKGROOT"
		make_tar_flatten_subdirs "$PKGROOT"
		exit 0
	;;
	adwaita-*)
		mkdir -pv ./wtf-autogen
		cp -vf "$_PKG_DIR/gnome-autogen.sh" ./wtf-autogen
		chmod +x ./wtf-autogen/gnome-autogen.sh
		export PATH="$PATH:$PWD/wtf-autogen"
		./autogen.sh 			\
			--prefix="$PKGPREFIX"
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
		PFXDEST="$PKGROOT$PKGPREFIX"
		# fix loader info
		LD_LIBRARY_PATH="$PFXDEST/lib"                                     \
		GDK_PIXBUF_MODULEDIR=$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders/   \
		"$PFXDEST/bin/gdk-pixbuf-query-loaders" >                          \
			"$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
		#cp "$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
		#	"$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache.old"
		sed -i "s|$PKGROOT$PKGPREFIX|$PKGPREFIX|" \
			"$PFXDEST/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
	;;
esac

make_tar_flatten_subdirs "$PKGROOT"
