#!/bin/sh
set -e
case "$PKGARCHIVE" in
	inetutils*)
		# logger is included in util-linux
		./configure 			\
			--prefix=/usr		\
			--disable-logger
	;;
	gnutls*)
		./configure 				\
			--prefix=/usr			\
			--disable-static		\
			--disable-heartbeat-support	\
			--enable-openssl-compatibility
	;;
	lynx*)
		./configure 			\
			--prefix=$PKGROOT
	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
case "$PKGARCHIVE" in
	iproute2*|lynx*)
		DESTDIR=$PKGROOT		\
		make install
	;;
	gnutls*)
		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;
	*)
		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;
esac

