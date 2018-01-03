#!/bin/sh
set -e

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/share/pkgconfig"
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	# TODO some of these might not be needed if using ardour bundled (not external libs option)
	libltc*)
		libtoolize --force
		aclocal
		autoheader
		automake --add-missing --foreign
		autoconf
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	fluidsynth*)
		sed -i 's#DEFAULT_SOUNDFONT#"share/soundfonts/default.sf2"#' \
							src/synth/fluid_synth.c
		libtoolize --force
		aclocal
		autoheader
		automake --add-missing --foreign
		autoconf
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	LRDF*)
		sh autogen.sh
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
	ardour*)
		sed -i "s#rev = fetch_git_revision.*#rev = '6.0-pre0'#" ./wscript
		./waf configure 		\
			--prefix="$PKGPREFIX"	\
			--no-phone-home		\
			--libjack=weak		\
			--with-backends=alsa,jack,dummy
			# broken gcc7?
			#--no-nls
		./waf
		./waf install --destdir="$PKGROOT"
		make_tar_flatten_subdirs "$PKGROOT"
		exit 0
	;;
	taglib*)
		cmake -G 'Unix Makefiles'		\
			-DCPACK_SET_DESTDIR="$PKGROOT"	\
			-DCMAKE_INSTALL_PREFIX="$PKGPREFIX"
	;;
	ladspa_sdk*)
		INC="$PKGROOT/include/"
		mkdir -pv "$INC"
		cp -v "src/ladspa.h" "$INC"
		make_tar "$PKGROOT"
		exit 0
	;;
	lilv-*|suil-*|sratom-*|sord-*|serd-*|lv2*|aubio*)
		./waf configure --prefix="$PKGPREFIX"
		./waf
		./waf install --destdir="$PKGROOT"
		make_tar_flatten_subdirs "$PKGROOT"
		exit 0
	;;
	db-*)
		cd build_unix
		../dist/configure 			\
			--prefix="$PKGPREFIX"
	;;
	fftw*)
		#--enable-shared		\
		#--enable-openmp		\
		#autoreconf
		if [ "$PKG" = "fftw3f" ]; then
			make clean
			./configure 			\
				--prefix="$PKGPREFIX"	\
				--enable-sse2		\
				--enable-threads	\
				--enable-float
		else
			./configure 			\
				--prefix="$PKGPREFIX"	\
				--enable-sse2
		fi
	;;
	rubberband*)
		#autoreconf
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
