#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	ncurses*)
		DESTDIR="$PKGROOT"				\
		./configure 					\
			--prefix="$PKGPREFIX"			\
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
			--prefix="$PKGROOT/$PKGPREFIX"	\
			--disable-kill
	;;
	kbd-1.15*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-nls
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
make install

case "$PKGARCHIVE" in
	ex-*)
		make_tar "$PKGROOT"
	;;
	*)
		make_tar_flatten_subdirs "$PKGROOT"
	;;
esac


