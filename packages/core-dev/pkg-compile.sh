#!/bin/sh
set -e
source "$PKGINCLUDE"

# XXX gcc install has some sort of race condition? but seriously i don't know what
# causes the failure and strace doesn't offer much helpful info either.
# to fix it you have to enter pod and DESTDIR=$PKGROOT make install,
# then cd $PKGROOT/usr && tar -cf ../usr.tar ./* && cd .. && rm -rf usr && touch /podhome/pkgbuild-core-dev/gcc-*/.pkg-built-gcc
# until i figure out what the f is causing ferror on stdout (in make source)
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
	Archive-Zip*)
		perl Makefile.PL
		sed -i "s#DESTDIR = #DESTDIR = $PKGROOT#" Makefile
	;;
	pkgconf*)
		./autogen.sh
		./configure							\
			--prefix="$PKGPREFIX"					\
			--with-system-libdir="/lib:$PKGPREFIX/lib"		\
			--with-system-includedir="$PKGPREFIX/include"		\
			--with-pkg-config-dir="$PKGPREFIX/lib/pkgconfig:$PKGPREFIX/share/pkgconfig"
	;;
	nasm*)
		./configure				\
			--prefix="$PKGROOT/$PKGPREFIX"
	;;
	gcc-*)
		# TODO handle version numbers globally somehow!!!
		#GCC_VERSION=${PKGARCHIVE#gcc-}
		#GCC_VERSION=${GCC_VERSION%.tar*}
		# TODO support subpackages for extra languages, gnat, objc, etc
		# and gcc-specs option in later pass after gcc has been installed
		case "$PKG" in
		gcc)
		if [ "$PKGNOCONF" == "" ]; then
			./configure				\
				--prefix="$PKGPREFIX"		\
				--disable-multilib		\
				--disable-bootstrap		\
				--disable-lto			\
				--with-system-zlib		\
				--enable-default-pie		\
				--enable-default-ssp		\
				--enable-secure-plt		\
				--enable-targets=all		\
				--enable-languages=c,c++
			# --enable-default-pie doesnt work on 5.4, use specs
		fi
		;;
		gcc-specs*)
		echo "no spec modifications to be made."
		exit -1
		##############################################################
		# adjust gcc specs
		# e.g: https://wiki.gentoo.org/wiki/Hardened/Toolchain
		##############################################################
		# enable relro linker flag by default
		gcc -dumpspecs | sed 's#%{pie:-pie}#%{pie:-pie} %{!norelro: -z relro} %{relro: }#' > \
			`dirname $(gcc --print-libgcc-file-name)`/specs

		;;
		*)
			echo "unknown gcc subpackage"
			exit -1
		;;
		esac
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

make "-j$JOBS" "$PKGBUILD_MAKE_FLAGS"
DESTDIR="$PKGROOT" make install

case "$PKGARCHIVE" in
pkgconf*)
	# OpenBSD pkgconf, needs symlink
	ln -sv pkgconf "$PKGROOT/$PKGPREFIX/bin/pkg-config"
;;
esac
make_tar_flatten_subdirs "$PKGROOT"
ls -lah "$PKGROOT"
