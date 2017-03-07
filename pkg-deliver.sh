#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#-----------------------------------------------------------------------------
#
set -e
#-----------------------------------------------------------------------------
if [ -z "$1" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-deliver <flockdir>"
	echo "PKGINSTALL should point to the base directory"
	echo "and not to any specific package prefix"
	exit -1
fi
# make absolute path
if [[ "$1" != /* ]]; then
	FLOCKDIR="$(pwd)/$1"
else
	FLOCKDIR="$1"
fi
# install packages into this location.
if [ "$PKGINSTALL" == "" ]; then
	PKGINSTALL="/usr/local"
fi

if [ "$PKGTMP" == "" ]; then
	# someplace mounted as tmpfs is ideal
	PKGTMP="$HOME/.pkg-deliver"
fi
if [ -e "$PKGTMP" ]; then
	rm -rvf "$PKGTMP"
fi
mkdir -p "$PKGTMP"

#
#-----------------------------------------------------------------------------


cd "$FLOCKDIR"
for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
	if [[ "$ITEM" != *.tar.* ]]; then
		#build pkgdist
		PKGDIST="pkgdist-$ITEM"
		while read LINE ;do
			PKGNAME="$(echo "$LINE" | cut -d " " -f 1)"
			PKGTAR="$(echo "$LINE" | cut -d " " -f 2)"
			_PKG_DIR="$PKGTMP/$PKGDIST/$PKGNAME"
			if [ -e "$_PKG_DIR" ]; then
				rm -rvf "./$_PKG_DIR"
			fi
			echo "extracing $PKGTAR"
			mkdir -p "$_PKG_DIR"
			cd "$_PKG_DIR"
			tar xf "$FLOCKDIR/$PKGTAR"
			cd "$FLOCKDIR"
		done < "$ITEM"
		pkg-install.sh "$PKGTMP/$PKGDIST" "$ITEM"
		rm -r "$_PKG_DIR"
	fi
	cd "$FLOCKDIR"
done
rm -r "$PKGTMP"
echo "delivered."
