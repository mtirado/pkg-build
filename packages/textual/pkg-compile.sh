#!/bin/sh
set -e
source "$PKGINCLUDE"

VIMRCPATH="$PKGPREFIX/etc/vimrc"
DOTEST=""
case "$PKGARCHIVE" in
	#case pkgname*)
	vim*)
		echo "#define SYS_VIMRC_FILE \"$VIMRCPATH\"" >> src/feature.h
		./configure 			\
			--prefix="$PKGPREFIX"	\
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
			--prefix="$PKGROOT"	\
			--disable-rpath		\
			--without-bash-malloc	\
			--disable-net-redirection
		#--enable-mem-scramble
		#--disable-largefile
		#--enable-static-link

	;;
	hunspell-*)
		autoreconf -vfi
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	dictionaries)
		# abiword at least looks in this locations,
		# not sure about other programs
		mkdir -vp "$PKGROOT/$PKGPREFIX/share/myspell/dicts"
		cp -vf ./* "$PKGROOT/$PKGPREFIX/share/myspell/dicts/"
		make_tar_flatten_subdirs "$PKGROOT"
		exit 0
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS" $DOTEST
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
	vim*)
		#don't overwrite ex with vim
		if [ -e "$PKGROOT/$PKGPREFIX/bin/ex" ]; then
			rm "$PKGROOT/$PKGPREFIX/bin/ex"
			rm "$PKGROOT/$PKGPREFIX/bin/view"
			rm "$PKGROOT/$PKGPREFIX/share/man/man1/ex.1"
			rm "$PKGROOT/$PKGPREFIX/share/man/man1/view.1"
		fi
		echo "installing default vimrc: $VIMRCPATH"
		mkdir -vp "$PKGROOT/$PKGPREFIX/etc"
		cp -fv "$PKGROOT/$PKGPREFIX/share/vim/vim74/vimrc_example.vim" \
			"$PKGROOT/$PKGPREFIX/etc/vimrc"
		make_tar_flatten_subdirs "$PKGROOT"
	;;
	bash*)
		make_tar "$PKGROOT"
	;;
	*)
		make_tar_flatten_subdirs "$PKGROOT"
	;;

esac
