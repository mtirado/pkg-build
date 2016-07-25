#!/bin/sh

set -e
case "$PKGARCHIVE" in
	perl*)
		export BUILD_ZLIB=False
		export BUILD_BZIP2=0
		sh Configure 	-des                               \
				-Dprefix=$PKGROOT                  \
				-Dvendorprefix=$PKGROOT            \
				-Dman1dir=$PKGROOT/share/man/man1  \
				-Dman3dir=$PKGROOT/share/man/man3  \
				-Dpager="/usr/bin/less -isR"       \
				-Duseshrplib
		unset BUILD_ZLIB BUILD_BZIP2
	;;
	bison*)
		./configure 			\
			--prefix=$PKGROOT
	;;
	pkgconf*)
		./configure                                      \
			--with-system-libdir=/usr/lib            \
			--with-system-includedir=/usr/include    \
			--with-pkg-config-dir=/usr/lib/pkgconfig \
			--prefix=$PKGROOT
	;;
	*)
		./configure 			\
			--prefix=$PKGROOT
esac

make -j$JOBS
make install

case "$PKGARCHIVE" in
pkgconf*)
	# OpenBSD pkgconf, needs symlink
	ln -sv pkgconf $PKGROOT/bin/pkg-config
;;
esac

