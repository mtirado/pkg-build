#!/bin/sh
set -e
case "$PKGARCHIVE" in
	inetutils*)
		# logger is included in util-linux
		./configure 			\
			--prefix=$PKGROOT	\
			--disable-logger
	;;
	iproute2*)
		./configure 			\
			--prefix=$PKGROOT
	;;
	iptables*)
		./configure 			\
			--prefix=$PKGROOT
	;;
	*)
		./configure 			\
			--prefix=$PKGROOT
	;;
esac

make -j$JOBS
case "$PKGARCHIVE" in
	iproute2*)
		DESTDIR=$PKGROOT		\
		make install
	;;
	*)
		make install
	;;
esac

