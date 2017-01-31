#!/bin/sh
set -e
source "$PKGINCLUDE"

# XXX gcc install has some sort of race condition? but seriously i don't know what
# causes the failure and strace doesn't offer much helpful info either.
# if you set PKGNOCONF=y and rerun it many times, eventually it will install.
if [ "$PKGNOCONF" == "" ]; then
case "$PKGARCHIVE" in
	perl*)
		export BUILD_ZLIB=False
		export BUILD_BZIP2=0
		sh Configure 	-des					\
				-Dprefix="$PKGPREFIX"			\
				-Dvendorprefix="$PKGPREFIX"		\
				-Dman1dir="$PKGPREFIX/share/man/man1"	\
				-Dman3dir="$PKGPREFIX/share/man/man3"	\
				-Dpager="$PKGPREFIX/bin/less -isR"	\
				-Duseshrplib
		unset BUILD_ZLIB BUILD_BZIP2
	;;
	pkgconf*)
		./configure							\
			--with-system-libdir="$PKGPREFIX/lib"			\
			--with-system-includedir="$PKGPREFIX/include"		\
			--with-pkg-config-dir="$PKGPREFIX/lib/pkgconfig"	\
			--prefix="$PKGPREFIX"
	;;
	nasm*)
		./configure				\
			--prefix="$PKGROOT/$PKGPREFIX"
	;;
	gcc-*)
		./configure				\
			--prefix="$PKGPREFIX"		\
			--disable-multilib		\
			--disable-bootstrap		\
			--with-system-zlib		\
			--enable-default-pie		\
			--enable-default-ssp		\
			--enable-secure-plt		\
			--enable-targets=all		\
			--enable-languages=c,c++
		# XXX how to turn on default relro?
		# --enable-default-pie doesnt work on 5.4 :(
	;;
	binutils-*)
		./configure				\
			--prefix="$PKGPREFIX"		\
			--enable-shared			\
			--enable-libssp			\
			--enable-vtable-verify
			#--disable-werror		\
			#--enable-gold			\

		#make "-j$JOBS"
		#DESTDIR="$PKGROOT" make tooldir=? install
		#make_tar_flatten_subdirs "$PKGROOT"
	;;
	gmp-*)
		./configure				\
			--prefix="$PKGPREFIX"		\
			--enable-cxx
	;;
	mpfr-*)
		./configure				\
			--prefix="$PKGPREFIX"		\
			--enable-thread-safe
	;;
	#mpc-*)
	#;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac
fi

make "-j$JOBS"
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
pkgconf*)
	# OpenBSD pkgconf, needs symlink
	ln -sv pkgconf "$PKGROOT/$PKGPREFIX/bin/pkg-config"
;;
esac

make_tar_flatten_subdirs "$PKGROOT"
