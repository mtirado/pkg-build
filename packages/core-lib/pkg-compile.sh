#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib/pkgconfig"
while read LINE ;do
	cd $CWD
	PKGROOT=$PKGDISTDIR/$(echo $LINE | cut -d " " -f 1)
	ARCHIVEDIR=$(echo $LINE | cut -d " " -f 2)
	ARCHIVEDIR=${ARCHIVEDIR%.tar.*}
	if [ ! -d "$ARCHIVEDIR" ]; then
		echo "archive dir $ARCHIVEDIR is missing"
		exit -1
	fi
	# skip completed builds
	if [ -e "$ARCHIVEDIR/.pkg-built" ]; then
		continue
	fi

	cd $ARCHIVEDIR
	echo "archive dir $ARCHIVEDIR"
	echo "pkg dir $PKGDIR"
	case "$ARCHIVEDIR" in
		#case pkgname*)
		#;;
		libgpg-error*)
			./configure 			\
				--prefix=$PKGROOT
			export PKG_LIBGPGERROR=$PKGROOT
		;;
		libgcrypt*)
			if [ -z "$PKG_LIBGPGERROR" ]; then
				echo "PKG_LIBGPGERROR dir is not set, use export"
				echo "and try again, or rm libgpg-error source dir"
				exit -1
			fi
			GPG_ERROR_CONFIG=$PKG_LIBGPGERROR/bin/gpg-error-config \
			GPG_ERROR_LIBS=$PKG_LIBGPGERROR/lib                    \
			GPG_ERROR_CFLAGS=$PKG_LIBGPGERROR/include	       \
			./configure 				               \
				--prefix=$PKGROOT
		;;
		p11-kit*)
			./configure 			\
				--prefix=$PKGROOT	\
				--with-trust-paths=/etc/pkcs11
			mkdir -pv $PKGROOT/etc/pkcs11
		;;
		libiconv*)
			# patch glibc C11 error
			patch -p1 < $PKGDIR/1-avoid-gets-error.patch
			./configure 			\
				--prefix=$PKGROOT
		;;
		*)
			./configure 			\
				--prefix=$PKGROOT
	esac

	make -j$JOBS
	make install

	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKGROOT/lib/pkgconfig"
	touch ".pkg-built"

done < $PKGDIR/wares

