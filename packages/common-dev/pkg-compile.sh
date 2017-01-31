#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	git*)
		PERL="/usr/bin/perl"
		autoreconf
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--without-iconv		\
			--without-python	\
			--without-tcltk		\
			--with-perl="$PERL"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
