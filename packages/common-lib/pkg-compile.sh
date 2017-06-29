#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	#
	#libiconv*)
	#	# patch glibc C11 error
	#	patch -p1 < $PKGDIR/1-avoid-gets-error.patch
	#	./configure 			\
	#		--prefix=$PKGROOT
	#;;
	sqlite*)
		CFLAGS="-DSQLITE_ENABLE_FTS3=1  		\
			-DSQLITE_ENABLE_COLUMN_METADATA=1	\
			-DSQLITE_ENABLE_UNLOCK_NOTIFY=1		\
			-DSQLITE_SECURE_DELETE=1		\
			-DSQLITE_ENABLE_DBSTAT_VTAB=1"		\
			./configure				\
				--prefix="$PKGPREFIX"		\

	;;
	glib*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-static	\
			--disable-libsystemd	\
			--disable-libelf	\
			--disable-xattr		\
			--disable-fam		\
			--disable-selinux	\
			--disable-mem-pools	\
			--with-pcre=internal
			# mem pools could improve performance, benchmark it.
	;;
	readline*)
		mkdir -p "$PKGROOT/$PKGPREFIX"
		./configure 				\
			--prefix="$PKGROOT/$PKGPREFIX"
	;;
	krb5-*)
		cd ./src
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-pkinit
			#pkinit implicit declaration errors
	;;
	boost_*)
		./bootstrap.sh			\
			--prefix="$PKGROOT/$PKGPREFIX"
		./b2
		./b2 install
		make_tar_flatten_subdirs "$PKGROOT"
		exit 0
	;;
	json-*)
		# gcc7 warns on switch fallthrough
		patch -p1 < "$_PKG_DIR/json-c-0.12.1.gcc7-case-fallthru.patch"
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
