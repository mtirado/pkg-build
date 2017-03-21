#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	inetutils*)
		# logger is included in util-linux
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-logger
	;;
	gnutls*)
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-static		\
			--disable-heartbeat-support
	;;
	dhcp*)
		JOBS=1
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	curl-*)
		# TODO install some certs
		./configure 					\
			--prefix="$PKGPREFIX"			\
			--with-ca-bundle=/etc/ssl/cacert.pem	\
			--with-ca-path=/etc/ssl/certs

			#--without-ssl				\
			#--with-gnutls				\

	;;
	iana-etc*)
		PKGPREFIX="/"
		make
		make DESTDIR="$PKGROOT" install
		make_tar "$PKGROOT"
		exit 0
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
case "$PKGARCHIVE" in
	#iproute2*)
	#	make_tar "$PKGROOT"
	#;;
	*)
		make_tar_flatten_subdirs "$PKGROOT"
	;;
esac

