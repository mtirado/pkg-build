#!/bin/sh
set -e

VIMRCPATH=/usr/etc/vimrc
DOTEST=""
case "$PKGARCHIVE" in
	#case pkgname*)
	vim*)
		echo "#define SYS_VIMRC_FILE \"$VIMRCPATH\"" >> src/feature.h
		./configure 			\
			--prefix=/usr		\
			--disable-netbeans	\
			--disable-xsmp		\
			--disable-xim		\
			--without-x		\
			--disable-gui		\
			--disable-xsmp-interact	\
			--disable-darwin	\
			--disable-selinux	\
			--disable-hangulinput	\
			--disable-fontset
			#--disable-gpm		\
			#--disable-sysmouse

		# some x11 stuff gets built in and causes hiccups if textual
		# is built after installing gui package groups.
		# make a separate gvim package if you want that (x clipboard)

		# XXX test fails regarding a "not a terminal" type error, which
		# /could/ be jettison bug regarding glibc not having fall back
		# to fd 0,1,2 stdio fd's if can't open /proc/self/0,1,2 symlinks
		#DOTEST="test"

		#parallel breakage
		JOBS=1
	;;
	bash*)
		./configure 			\
			--prefix=$PKGROOT	\
			--without-bash-malloc
	;;
	*)
		./configure 		\
			--prefix=/usr
esac

make -j$JOBS $DOTEST

case "$PKGARCHIVE" in
	vim*)

		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr

		#don't overwrite ex with vim
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
	#TODO move this to a package that installs to /bin, copy manually from /usr/bin > /bin for now
	bash*)
		DESTDIR=$PKGROOT    \
			make install
	;;
	*)
		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;

esac
