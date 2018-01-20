#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#-----------------------------------------------------------------------------
#
set -e
#-----------------------------------------------------------------------------
if [ -z "$1" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-deliver <flockdir> [override-dir]"
	echo "override-dir is optional, for customizing pkg contents on read-only media"
	echo "PKGINSTALL should point to the target install directory"
	exit -1
fi
# make absolute path
if [[ "$1" != /* ]]; then
	FLOCKDIR="$(pwd)/$1"
else
	FLOCKDIR="$1"
fi
if [ "$2" != "" ]; then
	OVERRIDE_DIR="$2"
	if [ ! -d "$OVERRIDE_DIR" ]; then
		echo "override-dir is not a dir: $OVERRIDE_DIR"
		exit -1
	fi
else
	OVERRIDE_DIR=""
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
# only overrides the contents file
if [ "$OVERRIDE_DIR" != "" ]; then
	CONTENTS_DIR="$OVERRIDE_DIR"
else
	CONTENTS_DIR="$FLOCKDIR"
fi
cd "$CONTENTS_DIR"
for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
	if [[ "$ITEM" != *.tar* ]]; then
		#build pkgdist
		PKGDIST="pkgdist-$ITEM"
		echo ""
		printf "extracting $ITEM: "
		while read LINE ;do
			PKGNAME="$(echo "$LINE" | cut -d " " -f 1)"
			PKGTAR="$(echo "$LINE" | cut -d " " -f 2)"
			_PKG_DIR="$PKGTMP/$PKGDIST/$PKGNAME"
			if [ -e "$_PKG_DIR" ]; then
				rm -rvf "$_PKG_DIR"
			fi
			printf "$PKGTAR "
			mkdir -p "$_PKG_DIR"
			cd "$_PKG_DIR"
			tar xf "$FLOCKDIR/$PKGTAR"
			cd "$CONTENTS_DIR"
		done < "$ITEM"
		echo ""
		pkg-install.sh "$PKGTMP/$PKGDIST" "$ITEM"
		rm -r "$_PKG_DIR"
	fi
done
rm -r "$PKGTMP"
echo "delivered."
