#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	ncurses*)
		DESTDIR=$PKGROOT				\
		./configure 					\
			--prefix=/usr				\
			--with-shared				\
			--without-debug				\
			--without-normal			\
			--enable-pc-files

	;;
	ex-*)
		sed -i "s|DESTDIR.*=|DESTDIR = $PKGROOT|" Makefile
		sed -i "s|/usr/ucb|/usr/bin|" Makefile
		sed -i "s|/usr/local|/|" Makefile
		sed -i "s|= termlib|= ncurses|" Makefile

	;;
	procps*)
		./configure 			\
			--prefix=/usr		\
			--disable-kill
	;;
	# XXX --disable-nls is used because i don't need this.
	kbd-1.15*)
		./configure 			\
			--prefix=/usr		\
			--disable-nls
	;;
	*)
		./configure 			\
			--prefix=/usr

esac

make "-j$JOBS"
make install

case "$PKGARCHIVE" in
	ex-*)
		make_tar_without_prefix "$PKGROOT"
	;;
	*)
		make_tar_prefix "$PKGROOT" /usr
	;;
esac


