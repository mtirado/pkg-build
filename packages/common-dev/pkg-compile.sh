#!/bin/sh
set -e
source "$PKGINCLUDE"
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

make -j"$JOBS"
DESTDIR="$PKGROOT"    \
	make install
make_tar_prefix "$PKGROOT" /usr
