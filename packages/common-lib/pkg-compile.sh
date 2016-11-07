#!/bin/sh
set -e
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
				--prefix=/usr			\

	;;
	glib*)
		./configure 			\
			--prefix=/usr		\
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
		mkdir -p $PKGROOT/usr
		./configure 			\
			--prefix=$PKGROOT/usr
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS

DESTDIR=$PKGROOT    \
	make install
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

