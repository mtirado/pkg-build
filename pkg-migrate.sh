#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# Creates a compressed snapshot of package state.
# Packages are stored as a line in package group file.
# note: running this script on new years eve may result in duplicate packages.
#-----------------------------------------------------------------------------
set -e
umask 0027
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
	PKGTMP="$HOME/.pkg-migrate"
fi
#-----------------------------------------------------------------------------
FLOCKDIR="$PWD/$1"
if [ -e "$PKGTMP" ]; then
	rm -rf $PKGTMP
fi
mkdir -p $PKGTMP

do_group_migrate() {
	PKGGROUP=$1
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

		# create temp dir
		if [ -e "$PKGTMP/$PKGNAME" ]; then
			rm -rv "$PKGTMP/$PKGNAME"
		fi
		mkdir "$PKGTMP/$PKGNAME";


		FILEGLOB=""
		cd $PKGINSTALL
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

		# tar globbing may be the only way to handle hardlinks
		# without depending on rsync?
		# TODO try --exclude-tag instead of globbing
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
			echo "              strip: ELF, ar"
			for FILE in $(find . -mindepth 1 -type f); do
				TEST=$(file "$FILE")
				if [[ "$TEST" == *ELF* ]]; then
					if [ -w $FILE ]; then
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
		tar -rf  "$FLOCKDIR/$PKGNAME" ./*
		rm -rf "$PKGTMP/$PKGNAME"
		echo "           compress: $PKGNAME.xz"
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
	echo ""
	echo "----------------------------------------------------------------"
	echo "         $PKGGROUP"
	echo "----------------------------------------------------------------"
	echo ""
	do_group_migrate "$PKGGROUP"
done
