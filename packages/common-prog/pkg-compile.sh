#!/bin/sh
set -e
case "$PKGARCHIVE" in
	qemu*)
		./configure 						\
			--prefix=/usr					\
			--disable-vnc					\
			--disable-bluez					\
			--target-list="i386-softmmu, i386-linux-user, arm-softmmu, arm-linux-user, mips-softmmu, mips-linux-user, x86_64-softmmu, x86_64-linux-user"
	;;
	*)
		./configure 			\
			--prefix=/usr
	;;
esac

make -j$JOBS

DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

