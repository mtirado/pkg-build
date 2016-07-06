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
	# skip completed builds
	if [ -e "$ARCHIVEDIR/.pkg-built" ]; then
		continue
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
		pkgconf*)
			./configure                                      \
				--with-system-libdir=/usr/lib            \
				--with-system-includedir=/usr/include    \
				--with-pkg-config-dir=/usr/lib/pkgconfig \
				--prefix=$PKGROOT
		;;
		*)
			./configure 			\
				--prefix=$PKGROOT
	esac

	make -j$JOBS
	make install

	case "$ARCHIVEDIR" in
		pkgconf*)
			# OpenBSD pkgconf, needs symlink
			ln -sv pkgconf $PKGROOT/bin/pkg-config
		;;
	esac

	touch ".pkg-built"

done < $PKGDIR/wares


