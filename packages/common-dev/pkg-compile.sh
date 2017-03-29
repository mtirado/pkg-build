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
	cmake-*)
		./bootstrap 			\
			--prefix="$PKGPREFIX"	\
			--system-curl		\
			--system-zlib		\
			--system-expat		\
			--system-libarchive	\
			--parallel=$JOBS
	;;
	ruby-*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--with-destdir="$PKGROOT"
	;;
	nim-*)
		# i guess throw it in /usr/bundles
		./build.sh
		./install.sh "$PKGROOT/bundles"
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
make_tar_flatten_subdirs "$PKGROOT"
