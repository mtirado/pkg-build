#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	gdb-*)
		./configure 				\
			--prefix="$PKGPREFIX/gdb"
	;;
	*)
		./configure 				\
			--prefix="$PKGPREFIX"
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
	gdb-*)
		# give gdb it's own directory so it doesn't overwrite binutils files
		# these are headers as well as static libs and translation files, so
		# instead of guessing which one is more up to date just provide both.
		ls -lah "$PKGROOT"
		ls -lah "$PKGROOT/$PKGPREFIX"
		mkdir -p "$PKGROOT/$PKGPREFIX/bin"
		mkdir -p "$PKGROOT/$PKGPREFIX/share/man"
		#cp -rv "$PKGROOT/$PKGPREFIX/include" "$PKGROOT/$PKGPREFIX/gdb/"
		cp -rv "$PKGROOT/$PKGPREFIX/gdb/share/man" "$PKGROOT/$PKGPREFIX/share"
		# symlink from bin to the gdb dir
		ln -s ../gdb/bin/gdb "$PKGROOT/$PKGPREFIX/bin/gdb"
		ln -s ../gdb/bin/gdb-core "$PKGROOT/$PKGPREFIX/bin/gdb-core"
		ln -s ../gdb/bin/gdbserver "$PKGROOT/$PKGPREFIX/bin/gdbserver"
	;;
esac
make_tar_flatten_subdirs "$PKGROOT"
