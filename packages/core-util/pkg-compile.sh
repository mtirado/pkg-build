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
		sed -i "s|PREFIX=/usr/local|PREFIX=/usr|" Makefile
	;;
	lsof_*)
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
		# patch for 3.01
		patch -p1 < $PKGDIR/cdrtools-3.01-fix-20151126-mkisofs-isoinfo.patch
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
	coreutils-*|lsscsi-*)
		PKGPREFIX="/"
		./configure 			\
			--prefix=/usr
	;;
	*)
		./configure 			\
			--prefix="$PKGPREFIX"
	;;
esac

make -j$JOBS
DESTDIR="$PKGROOT" make install
#make_tar "$PKGROOT"
make_tar_flatten_subdirs "$PKGROOT"
