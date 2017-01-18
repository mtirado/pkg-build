#!/bin/sh
set -e
source "$PKGINCLUDE"
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
			--disable-heartbeat-support
	;;
	dhcp*)
		JOBS=1
		./configure 			\
			--prefix=/usr
	;;
	curl-*)
		# TODO install some certs
		./configure 					\
			--prefix=/usr				\
			--with-ca-bundle=/etc/ssl/cacert.pem	\
			--with-ca-path=/etc/ssl/certs
	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
case "$PKGARCHIVE" in
	iproute2*)
		DESTDIR=$PKGROOT		\
			make install
		make_tar_without_prefix "$PKGROOT"
	;;
	*)
		DESTDIR=$PKGROOT    \
			make install
		make_tar_prefix "$PKGROOT" /usr
	;;
esac

