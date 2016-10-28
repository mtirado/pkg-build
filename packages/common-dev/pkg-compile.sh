#!/bin/sh

set -e
case "$PKGARCHIVE" in
	git*)
		# 1 job because perl is required, and
		# async PM.stamp / perl.mak fails (git-2.9.3)
		JOBS="1"
		./configure 			\
			--prefix=/usr		\
			--without-iconv		\
			--without-python	\
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

