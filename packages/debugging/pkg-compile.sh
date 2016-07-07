#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib/pkgconfig"
while read LINE ;do
	cd $CWD
	PKGROOT=$PKGDISTDIR/$(echo $LINE | cut -d " " -f 1)
	ARCHIVEDIR=$(echo $LINE | cut -d " " -f 2)
	ARCHIVEDIR=${ARCHIVEDIR%.tar.*}
	if [ ! -d "$ARCHIVEDIR" ]; then
		echo "archive dir $ARCHIVEDIR is missing"
		exit -1
	fi
	# skip completed builds
	if [ -e "$ARCHIVEDIR/.pkg-built" ]; then
		continue
	fi

	cd $ARCHIVEDIR
	echo "archive dir $ARCHIVEDIR"
	echo "pkg dir $PKGDIR"
	case "$ARCHIVEDIR" in
		#case pkgname*)
		#;;
		*)
			./configure 			\
				--prefix=$PKGROOT
	esac

	make -j$JOBS
	make install

	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKGROOT/lib/pkgconfig"
	touch ".pkg-built"

done < $PKGDIR/wares

