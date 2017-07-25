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
			--disable-heartbeat-support	\
			--with-included-unistring
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
	iproute2*)
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	nftables*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--without-cli
		#	--enable-pdf-doc
		# docbook2man has a bunch of sgml, etc deps i'm not bothering with
		# so there is no manual for this right now.
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
case "$PKGARCHIVE" in
	iproute2*)
		make_tar "$PKGROOT"
	;;
	*)
		make_tar_flatten_subdirs "$PKGROOT"
	;;
esac

