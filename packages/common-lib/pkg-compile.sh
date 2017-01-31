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
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
esac

make "-j$JOBS"
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
