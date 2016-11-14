#!/bin/sh
set -e
case "$PKGARCHIVE" in
	less-*)
		./configure 			\
			--prefix=/usr
		sed -i "s|DESTDIR.*=.*|DESTDIR = $PKGROOT|" Makefile
	;;
	pciutils*)
		# this is how you do it. ;)
	;;
	lsof_*)
		# this is not how you do it, :(
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
		exit 0
	;;
	lilo-*)
		# don't install boot images ( needs uuencode/sharutils )
		sed -i "/.*images.*/d" Makefile
		# do not want debian specifics
		sed -i "/.*hooks.*/d" Makefile
		sed -i "/.*scripts.*/d" Makefile
	;;
	bc-*)
		./configure 			\
			--prefix=$PKGROOT
		make -j$JOBS
		make install
		exit 0
	;;
	bin86-*)
		sed -i "s|PREFIX=.*|PREFIX=$PKGROOT|" Makefile
		mkdir -p $PKGROOT/bin
		mkdir -p $PKGROOT/lib
		mkdir -p $PKGROOT/man/man1
		make -j$JOBS
		make install
		exit 0
	;;
	util-linux*)
		./configure 				\
			--prefix=/usr			\
			--disable-makeinstall-chown	\
			--disable-use-tty-group
	;;
	htop*)
		./autogen.sh
		./configure 			\
			--prefix=/usr		\
			--disable-unicode
	;;
	gnufdisk*)
		./configure 			\
			--prefix=/usr		\
			--disable-cfdisk
	;;
	*)
		./configure 			\
			--prefix=/usr
esac

make -j$JOBS
DESTDIR=$PKGROOT    \
	make install
#empty /usr
cp -r $PKGROOT/usr/* $PKGROOT/
rm -rf $PKGROOT/usr

