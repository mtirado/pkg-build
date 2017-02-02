#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# Creates a compressed snapshot of package state.
# Packages are stored as a line in package group file.
# note: running this script on new years eve may result in duplicate packages.
#-----------------------------------------------------------------------------
set -e
umask 0022
#-----------------------------------------------------------------------------
if [ "$1" = "" ]; then
	echo "usage: pkg-migrate <flockdir>"
	echo "to select what packages to use use migrate PKGPREFIX"
	echo "PKGPREFIX=/root    -- /.packages "
	echo "PKGPREFIX=/usr     -- /usr/.packages "
	echo "anything deeper than 1 level is currently unsupported"
#	echo "PKGPREFIX=/local   -- /usr/local/.packages "
	exit -1
fi
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi
if [ "$PKGTMP" = "" ]; then
	# someplace mounted as tmpfs is ideal
	PKGTMP="$HOME/.pkg-migrate"
fi
#-----------------------------------------------------------------------------
FLOCKDIR="$PWD/$1"
# this temp dir is needed for stripping binaries
if [ -e "$PKGTMP" ]; then
	rm -rvf "$PKGTMP"
fi
mkdir -p "$PKGTMP"

# this is a bit of a hack
# pkgconfig adjustment needed and i'm undecided on how to handle that.
# TODO how to support deep prefixes like /usr/local/and/wherever/else
if [ "$PKGPREFIX" == "" ]; then
	PKGPREFIX="/usr"
elif [ "$PKGPREFIX" == "/" ]; then
	PKGPREFIX="/root"
fi
TARPREFIX="$(basename "$PKGPREFIX").tar"

do_group_migrate() {
	PKGGROUP="$1"
	GROUPDIR="$PKGINSTALL/.packages/$PKGGROUP"
	cd "$GROUPDIR"
	for PKG in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
		FILES=$(cat "$GROUPDIR/$PKG")
		# TODO add version number entry
		PKGNAME="$PKG-$(date +%G).tar"
		if [ -e "$FLOCKDIR/$PKGNAME.xz" ]; then
			echo "   skip: $PKGNAME.xz"
			continue
		elif [ -e "$FLOCKDIR/$PKGNAME" ]; then
			rm -f "$FLOCKDIR/$PKGNAME"
		fi
		echo "archive: $PKGNAME"

		# create temp dir for stripping binaries
		if [ -e "$PKGTMP/$PKGNAME" ]; then
			rm -rfv "$PKGTMP/$PKGNAME"
		fi
		mkdir "$PKGTMP/$PKGNAME";

		FILEGLOB=""
		cd "$PKGINSTALL"
		for FILE in $FILES; do
			if [ -d "$FILE" ]; then
				continue
			elif [ ! -L "$FILE" ] && [ ! -e "$FILE" ]; then
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
			FILEGLOB+="$FILE "
		done

		#is there another way to do this?
		tar -cf "$PKGTMP/$PKGNAME/temp.tar" $FILEGLOB
		cd "$PKGTMP/$PKGNAME"
		tar xf "temp.tar"
		rm "temp.tar"

		if [ "$STRIP_BINARIES" != "" ]; then
			echo "              strip: ELF, ar"
			for FILE in $(find . -mindepth 1 -type f); do
				TEST=$(file "$FILE")
				if [[ "$TEST" == *ELF* ]]; then
					if [ -w "$FILE" ]; then
						set +e
						strip --strip-unneeded "$FILE"
						set -e
					else
						chmod u+w "$FILE"
						set +e
						strip --strip-unneeded "$FILE"
						set -e
						chmod u-w "$FILE"
					fi
				elif [[ "$TEST" == *current\ ar\ archive* ]]; then
					if [ -w $FILE ]; then
						strip --strip-debug "$FILE"
					else
						chmod u+w "$FILE"
						strip --strip-debug "$FILE"
						chmod u-w "$FILE"
					fi
				fi
			done
		else
			echo "            nostrip."
		fi

		tar -rf  "$FLOCKDIR/$TARPREFIX" ./*
		cd "$FLOCKDIR"
		tar -cf  "$FLOCKDIR/$PKGNAME" "$TARPREFIX"
		rm "$FLOCKDIR/$TARPREFIX"
		rm -rf "$PKGTMP/$PKGNAME"
		echo "           compress: $PKGNAME.xz"
		xz "$FLOCKDIR/$PKGNAME"
		# TODO hash and/or sign package
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
	echo ""
	echo "----------------------------------------------------------------"
	echo "         $PKGGROUP"
	echo "----------------------------------------------------------------"
	echo ""
	do_group_migrate "$PKGGROUP"
done
rm -rf "$PKGTMP"
