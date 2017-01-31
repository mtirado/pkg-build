#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	qemu*)
		./configure 						\
			--prefix="$PKGPREFIX"				\
			--disable-vnc					\
			--disable-bluez					\
			--target-list="i386-softmmu, i386-linux-user, arm-softmmu, arm-linux-user, mips-softmmu, mips-linux-user, x86_64-softmmu, x86_64-linux-user"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
