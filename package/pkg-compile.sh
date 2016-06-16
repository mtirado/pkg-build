#!/bin/bash
# example build script for qemu i386 virtual machine
# assumes untarred directory is in cwd, and same as tar name without .tar.* extension.

set -e
umask 022

read -r LINE<$PKGDIR/wares
ARCHIVEDIR=${LINE%.tar.*}
if [ ! -d "$ARCHIVEDIR" ]; then
	echo "archive dir is missing: $ARCHIVEDIR"
	exit -1
fi

cd $ARCHIVEDIR

./configure 						\
		--prefix=$PKGDISTDIR			\
		--target-list=i386-softmmu
#		--enable-seccomp			\

make -j$JOBS
make install
