#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# Creates a compressed snapshot of package state.
# Packages are stored as a line in package group file.
#
#-----------------------------------------------------------------------------
set -e
umask 0077
#-----------------------------------------------------------------------------
if [ "$1" = "" ]; then
	echo "usage: pkg-migrate <flockdir>"
	exit -1
fi
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi
if [ "$PKGTMP" = "" ]; then
	# someplace mounted as tmpfs is ideal
	PKGTMP="/tmp/pkg-migrate-$LOGNAME[$UID]"
fi
#-----------------------------------------------------------------------------

FLOCKDIR="$PWD/$1"
if [ -e "$PKGTMP" ]; then
	set +e
	rm -r $PKGTMP
	set -e
fi
mkdir -p $PKGTMP

do_group_migrate() {
	PKGGROUP=$1
	for PKG in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
		FILES=$(cat "$PKG")
		# TODO add version number entry
		PKGNAME="$PKG-$(date --iso-8601=date).tar"
		#if [ -e "$FLOCKDIR/$PKGNAME.xz" ]; then
		if [ $(find $FLOCKDIR -iname "$PKG*.tar.*") ]; then
			echo "skipping $PKGNAME.xz"
			continue
		elif [ -e "$FLOCKDIR/$PKGNAME" ]; then
			rm -fv "$FLOCKDIR/$PKGNAME"
		fi
		echo "packaging $PKGNAME"

		# create temp dir
		if [ -e "$PKGTMP/$PKGNAME" ]; then
			rm -rv "$PKGTMP/$PKGNAME"
		fi
		mkdir "$PKGTMP/$PKGNAME";


		FILEGLOB=""
		cd $PKGINSTALL
		for FILE in $FILES; do
			if [ ! -L "$FILE" ] && [ ! -e "$FILE" ]; then
				echo "package file missing: $PKGINSTALL/$FILE"
				echo "press c key to continue"
				read -n 1 KEY
				if [ "$KEY" != "c" ] && [ "$KEY" != "C" ]; then
					exit -1
				fi
				continue
			fi
			MKPATH=$(dirname "$PKGTMP/$PKGNAME/$FILE")
			if [ ! -d "$MKPATH" ]; then
				mkdir -p "$MKPATH"
			fi
			echo "FILE:[$FILE ]"
			FILEGLOB+="$FILE "
		done

		# globbing may be the only way without depending on rsync?
		tar -cf "$PKGTMP/$PKGNAME/temp.tar" $FILEGLOB
		cd "$PKGTMP/$PKGNAME"
		tar xf "temp.tar"
		rm "temp.tar"

		# now create the real tar starting with metadata
		cp "$PKGINSTALL/.packages/$PKGGROUP/$PKG" .pkg-contents
		echo "$PKG" > .pkg-name
		tar -cf "$FLOCKDIR/$PKGNAME" .pkg-contents
		tar -rf "$FLOCKDIR/$PKGNAME" .pkg-name
		rm .pkg-contents
		rm .pkg-name
		if [ "$STRIP_BINARIES" != "" ]; then
			for FILE in $(find . -mindepth 1 -type f); do
				TEST=$(file "$FILE")
				if [[ "$TEST" == *ELF* ]]; then
					strip --strip-unneeded "$FILE"
				elif [[ "$TEST" == *current\ ar\ archive* ]]; then
					strip --strip-debug "$FILE"
				fi
			done
		fi
		tar -rf  "$FLOCKDIR/$PKGNAME" ./*
		cd "$PKGINSTALL/.packages/$PKGGROUP"
		rm -rf "$PKGTMP/$PKGNAME"
		xz "$FLOCKDIR/$PKGNAME"
		# TODO hash and/or sign package
		rm -fv "$FLOCKDIR/$PKGNAME"
		#add package to group file
		echo "$PKG $PKGNAME.xz" >> "$FLOCKDIR/$PKGGROUP"
	done
}

echo "begin migration $FLOCKDIR"
if [ ! -e "$FLOCKDIR" ]; then
	mkdir -vp "$FLOCKDIR"
fi

cd "$PKGINSTALL/.packages"
if [ $(find . -name '*~') ]; then
	echo "package directory has been edited and contains backup file(s)"
	echo "remove files with trailing ~ and try again."
	exit -1
fi
for PKGGROUP in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
	cd "$PKGINSTALL/.packages/$PKGGROUP"
	echo "migrate  $PKGGROUP"
	do_group_migrate "$PKGGROUP"
done
