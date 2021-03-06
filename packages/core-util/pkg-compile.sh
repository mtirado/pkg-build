#!/bin/sh
set -e
source "$PKGINCLUDE"
case "$PKGARCHIVE" in
	less-*)
		PKGPREFIX="/"
			./configure 			\
			--prefix="$PKGPREFIX"
		sed -i "s|DESTDIR.*=.*|DESTDIR = $PKGROOT|" Makefile
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	pciutils*)
		PKGPREFIX="/"
		sed -i "s|PREFIX=/usr/local|PREFIX=/|" Makefile
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	lsof_*)
		PKGPREFIX="/"
		FNAME=${PKGARCHIVE%.tar.gz}
		TARFILE="${FNAME}_src.tar"
		tar xf $TARFILE
		cd "${TARFILE%.tar}"
		./Configure -n linux
		make -j$JOBS
		MANDIR=$PKGROOT/man/man8
		BINDIR=$PKGROOT/bin
		mkdir -vp $MANDIR
		mkdir -vp $BINDIR
		cp -vf lsof $BINDIR
		cp -vf lsof.8 $MANDIR
		make_tar "$PKGROOT"
		exit 0
	;;
	lilo-*)
		PKGPREFIX="/"
		# don't install boot images ( needs uuencode/sharutils )
		sed -i "/.*images.*/d" Makefile
		# do not want debian specifics
		sed -i "/.*hooks.*/d" Makefile
		sed -i "/.*scripts.*/d" Makefile
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	bc-*)
		./configure 			\
			--prefix=$PKGROOT
		make -j$JOBS
		make install
		make_tar "$PKGROOT"
		exit 0
	;;
	bin86-*)
		sed -i "s|PREFIX=.*|PREFIX=$PKGROOT|" Makefile
		mkdir -p $PKGROOT/bin
		mkdir -p $PKGROOT/lib
		mkdir -p $PKGROOT/man/man1
		make -j$JOBS
		make install
		make_tar "$PKGROOT"
		exit 0
	;;
	util-linux*)
		PKGPREFIX="/"
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--disable-makeinstall-chown	\
			--disable-use-tty-group
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0

	;;
	kmod-*)
		PKGPREFIX="/"
		zlib_CFLAGS="-I/usr/include"		\
		liblzma_CFLAGS="-I/usr/include"		\
		zlib_LIBS="-L/lib -lz"			\
		liblzma_LIBS="-L/lib -llzma"		\
		./configure 				\
			--prefix="$PKGPREFIX"		\
			--bindir=/sbin			\
			--with-xz			\
			--with-zlib

		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install

		ln -svf /sbin/kmod "$PKGROOT/sbin/modprobe"
		ln -svf /sbin/kmod "$PKGROOT/sbin/lsmod"
		ln -svf /sbin/kmod "$PKGROOT/sbin/rmmod"
		ln -svf /sbin/kmod "$PKGROOT/sbin/depmod"
		ln -svf /sbin/kmod "$PKGROOT/sbin/insmod"
		ln -svf /sbin/kmod "$PKGROOT/sbin/modinfo"

		make_tar "$PKGROOT"
		exit 0
	;;
	htop*)
		./autogen.sh
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-unicode
	;;
	gnufdisk*)
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-cfdisk
	;;
	parted*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--without-readline
	;;
	cdrtools-*)
		JOBS=1
		# patch for 3.01
		patch -p1 < $_PKG_DIR/cdrtools-3.01-fix-20151126-mkisofs-isoinfo.patch
		PREFIX="$PKGPREFIX"	 \
			make -j$JOBS
		DESTDIR=$PKGROOT	\
			make install
		cp -r $PKGROOT/opt/schily/* $PKGROOT/
		rm -rf $PKGROOT/opt/schily
		rm -rf $PKGROOT/share/man/man3
		rm -rf $PKGROOT/share/man/man5
		rm -rf $PKGROOT/include
		rm -rf $PKGROOT/lib
		make_tar "$PKGROOT"
		exit 0
	;;
	LVM*)
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"
		make "-j$JOBS"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	bzip2-*)
		PKGPREFIX="/"
		make "-j$JOBS" -f Makefile-libbz2_so
		make clean
		make "-j$JOBS"
		make PREFIX="$PKGROOT" install
		mkdir -vp "$PKGROOT/usr/include"
		cp -vf bzip2-shared "$PKGROOT/bin/bzip2"
		cp -avf libbz2.so* "$PKGROOT/lib"
		ln -svf /lib/libbz2.so.1.0 "$PKGROOT/lib/libbz2.so"
		#rm -vf /usr/bin/{bunzip2,bzcat,bzip2}
		ln -svf bzip2 "$PKGROOT/bin/bunzip2"
		ln -svf bzip2 "$PKGROOT/bin/bzcat"
		mv -v "$PKGROOT/man" "$PKGROOT/usr/man"
		mv -v "$PKGROOT/include" "$PKGROOT/usr/include"
		make_tar "$PKGROOT"
		exit 0
	;;
	coreutils-*|lsscsi-*|diffutils-*|gzip-*|tar-*|grep-*|sed-*|findutils-*)
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	e2fsprogs-*)
		JOBS=1
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--bindir=/bin		\
			--sbindir=/sbin		\
			--with-root-prefix=""
		make -j$JOBS
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;
	xz-*|zlib-*)
		PKGPREFIX="/"
		./configure 			\
			--prefix="$PKGPREFIX"
		make -j$JOBS
		DESTDIR="$PKGROOT" make install
		make_tar "$PKGROOT"
		exit 0
	;;

	# needs systemd/udev though maybe eudev would work, or mdev?
	usbutils-*)
		./configure 			\
			--prefix="$PKGPREFIX"	\
			--disable-dependency-tracking
	;;

	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make -j$JOBS
DESTDIR="$PKGROOT" make install
make_tar_flatten_subdirs "$PKGROOT"
