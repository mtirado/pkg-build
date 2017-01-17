#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	p11-kit*)
		./configure 			\
			--prefix=/usr		\
			--without-libffi	\
			--with-trust-paths=/etc/pkcs11
		mkdir -pv $PKGROOT/etc/pkcs11
	;;
	expat*)
		./configure 			\
			--prefix=$PKGROOT
	;;
	#perl XML::Parser
	XML-Parser*)
		mkdir -p $PKGROOT/usr
		perl Makefile.PL PREFIX=$PKGROOT/usr INSTALLDIRS=perl
	;;
	#
	#libiconv*)
	#	# patch glibc C11 error
	#	patch -p1 < $PKGDIR/1-avoid-gets-error.patch
	#	./configure 			\
	#		--prefix=$PKGROOT
	#;;

	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS

case "$PKGARCHIVE" in
	expat*)
		#expat doesn't believe in DESTDIR?
		make install
		make_tar_without_prefix "$PKGROOT"
	;;
	*)
		DESTDIR=$PKGROOT    \
			make install
		make_tar_prefix "$PKGROOT" /usr
	;;
esac

