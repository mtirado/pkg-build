#!/bin/sh
set -e

case "$PKGARCHIVE" in
	pixman*)
		./configure 			\
		--prefix=/usr			\
		--disable-static		\
		--disable-openmp		\
		--disable-longsoon-mmi		\
		--disable-arm-simd		\
		--disable-arm-neon		\
		--disable-arm-iwmmxt		\
		--disable-arm-iwmmxt2		\
		--disable-mips-dspr2		\
		--disable-gtk			\
		--disable-libpng		\
		--disable-timers
	;;
	libdrm*)
		./configure 		\
		--prefix=/usr		\
		--disable-static	\
		--disable-intel		\
		--disable-radeon	\
		--disable-amdgpu	\
		--disable-nouveau	\
		--disable-vmwgfx
	;;
	libX11*)
		PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/share/pkgconfig	\
		./configure						\
		--prefix=/usr						\
		--disable-static					\
		--disable-tcp-transport					\
		--disable-ipv6						\
		--disable-local-transport				\
		--disable-secure-rpc					\
		--disable-xf86bigfont					\
		--disable-loadable-xcursor				\
		--disable-loadable-il8n					\
		--enable-xlocale					\
		--enable-xthreads					\
		--disable-xlocaledir
		#xkbcomp needs xlocale
		# glibc, whyunodothiis
		# --enable-malloc0returnsnull
		# any threaded clients will need this, or require specifically
		# building without thread support? which is a pretty big hassle
		#--disable-xthreads					\

	;;
	libSM*|libICE*|libXfont*)
		PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/share/pkgconfig	\
		./configure						\
			--prefix=/usr		\
			--disable-static
	;;
	libdmx*)

		# XXX glamour ??
		# fix redeclaration
		DEFSTR="HAVE__XEATDATAWORDS"
		sed -i "s|.*$DEFSTR.*|#define $DEFSTR 1|" config.h.in
		./configure			\
			--prefix=/usr		\
			--disable-static
	;;
	libepoxy*)
		#  NO CONFIGURE???
		export ACLOCAL="aclocal -I/usr/share/aclocal"
		#set +e
		./autogen.sh
		#set -e
		./configure			\
			--prefix=/usr		\
			--disable-static
	;;
	xorg-server*)
		PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/share/pkgconfig	\
		./configure 			\
		--prefix=/usr			\
		--disable-static		\
		--disable-largefile		\
		--disable-visibility		\
		--disable-aiglx			\
		--disable-composite		\
		--disable-mitshm		\
		--disable-xres			\
		--disable-record		\
		--disable-xvmc			\
		--disable-screensaver		\
		--disable-xdmcp			\
		--disable-xdmcp-auth-1		\
		--disable-glx			\
		--disable-dri			\
		--disable-dri2			\
		--disable-config-hal		\
		--disable-dri3			\
		--disable-present		\
		--disable-xinerama		\
		--disable-xace			\
		--disable-dbe			\
		--disable-dpms			\
		--disable-config-udev		\
		--disable-config-udev-kms	\
		--disable-wscons		\
		--disable-windowswm		\
		--disable-xwin			\
		--disable-linux-acpi		\
		--disable-linux-apm		\
		--disable-systemd-logind	\
		--disable-suid-wrapper		\
		--disable-standalone-xpbproxy	\
		--disable-xnest			\
		--disable-xephyr		\
		--disable-kdrive		\
		--disable-kdrive-kbd		\
		--disable-kdrive-mouse		\
		--disable-kdrive-evdev		\
		--disable-libunwind		\
		--disable-xshmfence		\
		--disable-tcp-transport		\
		--disable-ipv6			\
		--disable-listen-local		\
		--disable-local-transport	\
		--disable-secure-rpc		\
		--disable-xselinux		\
		--disable-xcsecurity		\
		--disable-libdrm		\
		--disable-dga			\
		--enable-xv			\
		--enable-xorg			\
		--disable-xwayland		\
		--with-xkb-output=/var/lib/xkb
		#--enable-xv needed for xf86-video-modesetting driver

		# fbdev might be broken in qemu, TODO test on hardware
		#--enable-xfbdev		\
		#--enable-vgahw			\
		#--enable-pciaccess		\
		#--enable-clientids		\
		#--enable-xvfb			\
		#--enable-unix-transport	\
		#--enable-xfake			\
		#--enable-xf86vidmode		\
		#--enable-xfree86-utils		\
		#--enable-int10-module		\
		#--enable-dmx			\
		#--enable-glamor		\
		#--enable-xwayland		\
		#--disable-glamor		\
		#--disable-int10-module		\
		#--disable-xtrans-send-fds	\
		#--disable-pciaccess		\
		#--disable-xfake		\
		#--disable-xfbdev		\
		#--disable-xf86vidmode		\
		#--disable-xfree86-utils	\
	;;
	xkbcomp*)
		./configure 		\
		--prefix=/usr		\
		--disable-static
	;;
	xtrans*)
		./configure 		\
		--prefix=$PKGROOT	\
		--disable-static
	;;
	libXt*)
		./configure 		\
		--prefix=/usr		\
		--disable-static	\
		--disable-xkb		\
		--without-glib
	;;
	xkeyboard-config*)
		./configure 		\
		--disable-static	\
		--prefix=/usr		\
		--disable-nls
	;;
	*)
		./configure 		\
		--disable-static	\
		--prefix=/usr
	;;
esac


# install
case "$PKGARCHIVE" in
	xtrans*)
		# xtrans ignores DESTDIR?
		make -j$JOBS
		make install
		# ugh...
		make install-data-am
	;;
	xkbdata*)
		make -j$JOBS
		DESTDIR=$PKGROOT	\
		make install
		# flatten /usr
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
		# setup base
		cp $PKGROOT/share/X11/xkb/rules/xorg \
			$PKGROOT/share/X11/xkb/rules/base
	;;
#	util-macro*)
#		make -j$JOBS
#		make install
#	;;
	xorg-server*)
		make -j$JOBS
		DESTDIR=$PKGROOT	\
			make install
		# flatten /usr
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
		mkdir -p $PKGROOT/var/log
		# XXX right now you have to manually chmod +s /usr/bin/Xorg
		# or else it will be unable to do certain ioctl's ?
		# i'm not 100% sure yet what the hurdle for securing Xorg is.
	;;
	*)
		make -j$JOBS
		DESTDIR=$PKGROOT	\
		make install
		# flatten /usr
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;
esac


