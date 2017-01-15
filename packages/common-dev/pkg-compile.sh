#!/bin/sh

set -e
case "$PKGARCHIVE" in
	git*)
		autoreconf
		./configure 			\
			--prefix=/usr		\
			--without-iconv		\
			--without-python	\
			--without-tcltk		\
			--with-perl=/usr/bin/perl
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

