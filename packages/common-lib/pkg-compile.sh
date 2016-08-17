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
	# TODO test out other options
	freetype*)
		DEFSTR="FT_CONFIG_OPTION_PIC"
		sed -i "s|.*$DEFSTR.*|#define $DEFSTR|" devel/ftoption.h
		DEFSTR="FT_CONFIG_OPTION_SUBPIXEL_RENDERING"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="FT_CONFIG_OPTION_ADOBE_GLYPH_LIST"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="FT_CONFIG_OPTION_MAC_FONTS"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="FT_CONFIG_OPTION_INCREMENTAL"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="FT_CONFIG_OPTION_USE_HARFBUZZ"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h

		DEFSTR="TT_CONFIG_OPTION_BYTECODE_INTERPRETER"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="TT_CONFIG_OPTION_SUBPIXEL_HINTING"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="TT_CONFIG_OPTION_GX_VAR_SUPPORT"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="TT_CONFIG_OPTION_BDF"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="TT_CONFIG_OPTION_NO_MM_SUPPORT"
		sed -i "s|#undef.*$DEFSTR.*|#define $DEFSTR|" devel/ftoption.h

		DEFSTR="AF_CONFIG_OPTION_CJK"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="AF_CONFIG_OPTION_INDIC"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h
		DEFSTR="AF_CONFIG_OPTION_USE_WARPER"
		sed -i "s|#define.*$DEFSTR.*|#undef $DEFSTR|" devel/ftoption.h

		./configure 			\
			--prefix=/usr
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

