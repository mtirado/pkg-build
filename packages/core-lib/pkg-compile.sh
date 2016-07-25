#!/bin/sh
set -e
case "$PKGARCHIVE" in
	p11-kit*)
		./configure 			\
			--prefix=$PKGROOT	\
			--without-libffi	\
			--with-trust-paths=/etc/pkcs11
		mkdir -pv $PKGROOT/etc/pkcs11
	;;
	#libiconv*)
	#	# patch glibc C11 error
	#	patch -p1 < $PKGDIR/1-avoid-gets-error.patch
	#	./configure 			\
	#		--prefix=$PKGROOT
	#;;
	# TODO move this to a core GUI package, and test out these options
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
			--prefix=$PKGROOT
	;;
	*)
		./configure 			\
			--prefix=$PKGROOT
esac

make -j$JOBS
make install


