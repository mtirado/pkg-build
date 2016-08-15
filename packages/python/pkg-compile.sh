#!/bin/sh
set -e
case "$PKGARCHIVE" in
	setuptools*)
		mkdir -p $PKGROOT/lib/python2.7/site-packages
		PYTHONPATH=$PKGROOT/lib/python2.7/site-packages/		\
		python setup.py install --prefix=$PKGROOT
		exit 0
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

