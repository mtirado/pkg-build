#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#-----------------------------------------------------------------------------
#
set -e
#-----------------------------------------------------------------------------
if [ -z "$1" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-deliver <flockdir>"
	exit -1
fi
# make absolute path
if [[ "$1" != /* ]]; then
	FLOCKDIR="$(pwd)/$1"
else
	FLOCKDIR="$1"
fi
# install packages into this location.
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi
#-----------------------------------------------------------------------------


CWD=$(pwd)
cd $FLOCKDIR
for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
	if [[ "$ITEM" != *.tar.* ]]; then
		#build pkgdist
		PKGDIST="pkgdist-$ITEM"
		while read LINE ;do
			PKGNAME="$(echo $LINE | cut -d " " -f 1)"
			PKGTAR="$(echo $LINE | cut -d " " -f 2)"
			PKGDIR="$CWD/$PKGDIST/$PKGNAME"
			if [ -e "$PKGDIR" ]; then
				if [ -e "$PKGDIR/.pkg-name" ]; then
					rm -rvf "./$PKGDIR"
				else
					continue
				fi
			fi
			echo "extracing $PKGTAR"
			mkdir -p $PKGDIR
			cd $PKGDIR
			tar xf $FLOCKDIR/$PKGTAR
			rm -f podhome/.pkg-contents
			rm -f podhome/.pkg-name
			cd $FLOCKDIR
		done < "$ITEM"
		pkg-install.sh $CWD/$PKGDIST $ITEM
	fi
	cd $FLOCKDIR
done
echo "delivered."
