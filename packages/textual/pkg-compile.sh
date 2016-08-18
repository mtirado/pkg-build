#!/bin/sh
set -e

VIMRCPATH=/usr/etc/vimrc
DOTEST=""
case "$PKGARCHIVE" in
	#case pkgname*)
	vim*)
		echo "#define SYS_VIMRC_FILE \"$VIMRCPATH\"" >> src/feature.h
		./configure --prefix=/usr
		# XXX this fails reagrding a "not a terminal" type error, which
		# /could/ be jettison bug regarding glibc not having fall back
		# to fd 0,1,2 stdio fd's if can't open /proc/self/0,1,2 symlinks
		#DOTEST="test"
		#parallel breakage
		JOBS=1
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS $DOTEST
DESTDIR=$PKGROOT    \
	make install
#empty /usr
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

case "$PKGARCHIVE" in
	vim*)
		#don't overwrite ex with vim, ex works better on TERM=dumb
		if [ -e "$PKGROOT/bin/ex" ]; then
			rm $PKGROOT/bin/ex
			rm $PKGROOT/bin/view
			rm $PKGROOT/share/man/man1/ex.1
			rm $PKGROOT/share/man/man1/view.1
		fi
		echo "installing default vimrc: $VIMRCPATH"
		mkdir -vp $PKGROOT/etc
		cp -fv $PKGROOT/share/vim/vim74/vimrc_example.vim $PKGROOT/etc/vimrc
	;;
esac
