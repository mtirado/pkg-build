#!/bin/bash
set -e
umask 022
if [ "$1" = "" ]; then
	echo "usage: pkg-prepare <pkg-dir>"
	exit -1
fi

PKGDIR="$1"
cd $PKGDIR
#-----------------------------------------------------------------------------
# download / extract packages  TODO checksum + sig
#-----------------------------------------------------------------------------
# TODO download remote source packages if not local
# and also file verification, size maybe?
# support for different archive file types?
echo "acquiring and unpacking source archives..."
while read LINE; do
	ARCHIVE=$(echo $LINE | cut -d " " -f 1)
	echo "tar xf $ARCHIVE"
	tar xf $ARCHIVE
done <wares
echo "done, ready for pkg-build"



