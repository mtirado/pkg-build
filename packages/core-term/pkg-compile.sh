#!/bin/sh
set -e

CURSES_PREFIX=/usr
case "$PKGARCHIVE" in
	ncurses*)
		DESTDIR=$PKGROOT				\
		./configure 					\
			--prefix=$CURSES_PREFIX			\
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
			--prefix=$PKGROOT	\
			--disable-kill
	;;
	# XXX --disable-nls is used because i don't need this.
	# sorry rest of world  :P
	kbd-1.15*)
		./configure 			\
			--prefix=$PKGROOT	\
			--disable-nls
	;;
	*)
		./configure 			\
			--prefix=$PKGROOT

esac

make -j$JOBS
make install

case "$PKGARCHIVE" in
	ncurses*)
		mv -fv $PKGROOT/$CURSES_PREFIX/* $PKGROOT/
		rm -rfv $PKGROOT/$CURSES_PREFIX
	;;
esac


