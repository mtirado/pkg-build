#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '

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
		perl*)
			export BUILD_ZLIB=False
			export BUILD_BZIP2=0
			sh Configure 	-des                               \
					-Dprefix=$PKGROOT                  \
					-Dvendorprefix=$PKGROOT            \
					-Dman1dir=$PKGROOT/share/man/man1  \
					-Dman3dir=$PKGROOT/share/man/man3  \
					-Dpager="/usr/bin/less -isR"       \
					-Duseshrplib
			make -j$JOBS
			make install
			unset BUILD_ZLIB BUILD_BZIP2
			export PERL=$PKGROOT/bin/perl
		;;
		bison*)
			./configure 			\
				--prefix=$PKGROOT
			export YACC=$PKGROOT/bin/yacc
		;;
		*)
			./configure 			\
				--prefix=$PKGROOT
	esac

	make -j$JOBS
	make install


done < $PKGDIR/wares

