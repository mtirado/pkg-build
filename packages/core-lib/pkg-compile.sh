#!/bin/sh
set -e
source "$PKGINCLUDE"

case "$PKGARCHIVE" in
	p11-kit*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--without-libffi	\
			--with-trust-paths=/etc/pkcs11
		mkdir -pv "$PKGROOT/etc/pkcs11"
	;;
	expat*)
		# how quaint
		export INSTALL_ROOT="$PKGROOT"
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	#perl XML::Parser
	XML-Parser*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		perl Makefile.PL PREFIX="$PKGROOT/$PKGPREFIX" INSTALLDIRS=perl
	;;
	#
	#libiconv*)
	#	# patch glibc C11 error
	#	patch -p1 < $PKGDIR/1-avoid-gets-error.patch
	#	./configure 			\
	#		--prefix=$PKGROOT
	#;;
	glibc-*)
		# JOBS=1 because write stdout error make install bug
		JOBS=1
		ORIGPREFIX="$PKGPREFIX"
		PKGPREFIX="/"
		ETCDIR="$PKGROOT/$PKGPREFIX/etc"
		BDIR=".unrelated-build-dir"
		KERN="3.10"
		mkdir -vp "$BDIR"
		cd "$BDIR"
		../configure 					\
			--prefix="$ORIGPREFIX"			\
			--disable-profile			\
			--enable-kernel="$KERN"			\
			--enable-stackguard-randomization	\
			--enable-stack-protector=strong		\
			--enable-bind-now
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		echo "# autogenerated nsswitch.conf"	>  "$ETCDIR/nsswitch.conf"
		echo "passwd: 		files" 		>> "$ETCDIR/nsswitch.conf"
		echo "shadow: 		files" 		>> "$ETCDIR/nsswitch.conf"
		echo "group: 		files" 		>> "$ETCDIR/nsswitch.conf"
		echo "hosts: 		files dns" 	>> "$ETCDIR/nsswitch.conf"
		echo "networks:		files" 		>> "$ETCDIR/nsswitch.conf"
		echo "protocols:	files" 		>> "$ETCDIR/nsswitch.conf"
		echo "services:		files" 		>> "$ETCDIR/nsswitch.conf"
		echo "ethers:		files" 		>> "$ETCDIR/nsswitch.conf"
		make_tar "$PKGROOT"
		exit 0
	;;
	libusb-*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-udev
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"

case "$PKGARCHIVE" in
	#expat*)
		#expat doesn't believe in DESTDIR?
	#	make install
	#	make_tar "$PKGROOT"
	#;;
	*)
		DESTDIR="$PKGROOT" make install
		make_tar_flatten_subdirs "$PKGROOT"
	;;
esac

