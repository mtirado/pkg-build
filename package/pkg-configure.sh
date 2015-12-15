#!/bin/bash
# basic configure script. any packages that require multiple archives will
# need to be a little more complex; this is good enough for most cases.
# assumes untarred directory is same as filename without .tar.* extension.
set -e
umask 022
read -r LINE<wares
ARCHIVEDIR=${LINE%.tar.*}
cd $ARCHIVEDIR
echo "$ARCHIVEDIR/configure"

#
./configure 						\
	       	--prefix=$PKGDISTDIR			\
		--target-list=i386-linux-user
#		--enable-seccomp			\

