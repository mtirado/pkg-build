#!/bin/sh

set -e
case "$PKGARCHIVE" in
	perl*)
		export BUILD_ZLIB=False
		export BUILD_BZIP2=0
		sh Configure 	-des                               \
				-Dprefix=/usr           	   \
				-Dvendorprefix=/usr	           \
				-Dman1dir=/usr/share/man/man1      \
				-Dman3dir=/usr/share/man/man3  	   \
				-Dpager="/usr/bin/less -isR"       \
				-Duseshrplib
		unset BUILD_ZLIB BUILD_BZIP2
	;;
	pkgconf*)
		./configure                                      \
			--with-system-libdir=/usr/lib            \
			--with-system-includedir=/usr/include    \
			--with-pkg-config-dir=/usr/lib/pkgconfig \
			--prefix=/usr
	;;
	nasm*)
		./configure 			\
			--prefix=$PKGROOT/usr
	;;
	gcc-*)
		./configure                     \
		--prefix=/usr			\
		--disable-multilib              \
		--disable-bootstrap             \
		--with-system-zlib              \
		--enable-default-pie            \
		--enable-default-ssp		\
		--enable-secure-plt		\
		--enable-targets=all		\
		--enable-languages=c,c++

	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

case "$PKGARCHIVE" in
pkgconf*)
	# OpenBSD pkgconf, needs symlink
	ln -sv pkgconf $PKGROOT/bin/pkg-config
;;
esac

