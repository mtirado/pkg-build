#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	libX11*)
		./configure							\
		--prefix="$PKGPREFIX"						\
		--disable-static						\
		--disable-tcp-transport						\
		--disable-ipv6							\
		--disable-local-transport					\
		--disable-secure-rpc						\
		--disable-xf86bigfont						\
		--disable-loadable-xcursor					\
		--disable-loadable-il8n						\
		--enable-xlocale						\
		--enable-xthreads						\
		--disable-xlocaledir
		#xkbcomp needs xlocale
		# glibc, whyunodothiis
		# --enable-malloc0returnsnull
		# any threaded clients will need this, or require specifically
		# building without thread support? which is a pretty big hassle
		#--disable-xthreads					\

	;;
	libSM*|libICE*|libXfont*)
		./configure							\
			--prefix="$PKGPREFIX"					\
			--disable-static
	;;
	libdmx*)

		# XXX glamour ??
		# fix redeclaration
		DEFSTR="HAVE__XEATDATAWORDS"
		sed -i "s|.*$DEFSTR.*|#define $DEFSTR 1|" config.h.in
		./configure			\
			--prefix="$PKGPREFIX"	\
			--disable-static
	;;
	libepoxy*)
		#  NO CONFIGURE???
		export ACLOCAL="aclocal -I$PKGPREFIX/share/aclocal"
		#set +e
		./autogen.sh
		#set -e
		./configure			\
			--prefix="$PKGPREFIX"	\
			--disable-static
	;;
	xorg-server*)
		./configure 			\
		--prefix="$PKGPREFIX"		\
		--disable-visibility		\
		--disable-aiglx			\
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
		--disable-kdrive-evdev		\
		--disable-libunwind		\
		--disable-tcp-transport		\
		--disable-ipv6			\
		--disable-listen-local		\
		--disable-listen-tcp		\
		--disable-local-transport	\
		--disable-secure-rpc		\
		--disable-xselinux		\
		--disable-xcsecurity		\
		--disable-libdrm		\
		--disable-dga			\
		--disable-xwayland		\
		--disable-xshmfence		\
		--disable-glamor		\
		--disable-xephyr		\
		--enable-composite		\
		--enable-xv			\
		--enable-xorg			\
		--disable-xnest			\
		--with-xkb-output=/var/lib/xkb
		#--enable-xv needed for xf86-video-modesetting driver

		# TODO don't think weneed these, testing things...
		#--disable-mitshm		\
		#--disable-static		\
		#--disable-largefile		\
		#--disable-kdrive		\
		#--disable-kdrive-kbd		\
		#--disable-kdrive-mouse		\


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
		--prefix="$PKGPREFIX"	\
		--disable-static
	;;
	xtrans*)
		./configure 		\
		--prefix="$PKGROOT"	\
		--disable-static
	;;
	libXt*)
		./configure 		\
		--prefix="$PKGPREFIX"	\
		--disable-static	\
		--disable-xkb		\
		--without-glib
	;;
	xkeyboard-config*)
		./autogen.sh
		./configure 			\
			--disable-static	\
			--prefix="$PKGPREFIX"
	;;
	xf86-video-dummy*)
		./configure 		\
		--disable-static	\
		--prefix="$PKGPREFIX"	\
		--disable-dga
	;;
	*)
		./configure 		\
		--disable-static	\
		--prefix="$PKGPREFIX"
	;;
esac


# install
case "$PKGARCHIVE" in
	xtrans*)
		# xtrans ignores DESTDIR?
		make "-j$JOBS"
		make install
		# ugh...
		make install-data-am
		make_tar "$PKGROOT"
	;;
	xkbdata*)
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		# ugh crash on kbd input if we don't do this...
		cp "$PKGROOT/$PKGPREFIX/share/X11/xkb/rules/xorg" \
			"$PKGROOT/$PKGPREFIX/share/X11/xkb/rules/base"
		make_tar_flatten_subdirs "$PKGROOT"
	;;
#	util-macro*)
#		make -j$JOBS
#		make install
#		make_tar_without_prefix "$PKGROOT"
#	;;
	xorg-server*)
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		mkdir -p "$PKGROOT/$PKGPREFIX/var/log"
		make_tar_flatten_subdirs "$PKGROOT"
		# XXX right now you have to manually chmod +s /usr/bin/Xorg
		# or else it will be unable to do certain ioctl's ?
		# i'm not 100% sure yet what the hurdle for securing Xorg is.
	;;
	*)
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar_flatten_subdirs "$PKGROOT"
	;;
esac


