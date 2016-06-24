#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '

export PKG_CONFIG_PATH="/usr/lib/pkgconfig"
while read LINE ;do
	cd $CWD
	PKGROOT=$PKGDISTDIR/$(echo $LINE | cut -d " " -f 1)
	ARCHIVEDIR=$(echo $LINE | cut -d " " -f 2)
	ARCHIVEDIR=${ARCHIVEDIR%.tar.*}
	if [ ! -d "$ARCHIVEDIR" ]; then
		echo "archive dir $ARCHIVEDIR is missing"
		exit -1
	fi

	cd $ARCHIVEDIR
	echo "archive dir $ARCHIVEDIR"
	echo "pkg dir $PKGDIR"
	case "$ARCHIVEDIR" in
		inetutils*)
			# logger is included in util-linux
			./configure 			\
				--prefix=$PKGROOT	\
				--disable-logger
			make -j$JOBS
			make install
		;;
		iproute2*)
			./configure 			\
				--prefix=$PKGROOT
			make -j$JOBS
			DESTDIR=$PKGROOT		\
			make install
		;;
		*)
			./configure 			\
				--prefix=$PKGROOT
			make -j$JOBS
			make install
	esac

	#find deps as we build
	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKGROOT/lib/pkgconfig"

done < $PKGDIR/wares

