#!/bin/sh
set -e
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
	;;
	*)
		DESTDIR=$PKGROOT    \
			make install
		cp -r $PKGROOT/usr/* $PKGROOT/
		rm -rf $PKGROOT/usr
	;;
esac

