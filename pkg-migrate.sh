#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# Creates a compressed snapshot of package state.
# Packages are stored as a line in package group file.
#
# caveats: running this script on new years eve may result in duplicate packages.
#          PKGPREFIX can only be used for top level directories of / and
#          it will default to /usr. /root is a special case meaning / and thus
#          the real /root directory can never be a PKGPREFIX.
#-----------------------------------------------------------------------------
set -e
umask 0022
SINGLEPKG=""
GROUPPKG=""
#-----------------------------------------------------------------------------
if [ "$1" == "" ]; then
	echo "PKGINSTALL=/usr"
	echo "PKGINSTALL=/"
	echo "PKGINSTALL=/where/is/your/packages/dir"
	echo ""
	echo "usage: pkg-migrate <flock-name> <optional group-name or pkg-name>"
	echo "optionally specify pkg-name, or pkg-group-name instead of full migration."
	exit -1
fi
if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi
if [ "$PKGTMP" = "" ]; then
	# someplace mounted as ramfs or tmpfs is ideal
	PKGTMP="$HOME/.pkg-migrate"
fi
if [ "$2" != "" ]; then
	# check group dirs first
	SINGLEPKG=$(find "$PKGINSTALL/.packages" -maxdepth 1 -type d -name "$2" -printf '%f\n')
	if [ "$SINGLEPKG" != "" ]; then
		GROUPPKG=$(basename "$SINGLEPKG")
		SINGLEPKG=""
	else
		SINGLEPKG=$(find "$PKGINSTALL/.packages" -type f -name "$2")
		if [ "$SINGLEPKG" == "" ]; then
			echo "package $2 not found"
			exit -1
		fi
		SINGLEPKG="$2"
	fi
	if [ "$SINGLEPKG" == "" ] && [ "$GROUPPKG" == "" ]; then
		echo "could not find group or package $2"
		exit -1
	fi
fi
#-----------------------------------------------------------------------------
FLOCKDIR="$PWD/$1"
# this temp dir is needed for stripping binaries
if [ -e "$PKGTMP" ]; then
	rm -rvf "$PKGTMP"
fi
mkdir -p "$PKGTMP"

# this is a bit of a hack, tar filename stores top level install dir.
# pkgconfig adjustment needed and i'm undecided on how to handle that.
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

	if [ "$SINGLEPKG" == "" ]; then
		echo ""
		echo "----------------------------------------------------------------"
		echo "         $PKGGROUP"
		echo "----------------------------------------------------------------"
		echo ""
	fi


	for PKG in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do

# allow spaces and tabs in filenames
IFS="
"
		if [ "$SINGLEPKG" ]; then
			if [ "$PKG" != "$SINGLEPKG" ]; then
				continue
			fi
			echo ""
			echo "----------------------------------------------------------------"
			echo "         $SINGLEPKG"
			echo "----------------------------------------------------------------"
			echo ""
		fi

		# FIXME added -v, we also need to check for unexpected  . files and ~ files...
		FILES=$(cat -v "$GROUPDIR/$PKG")
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
				echo "continue..."
				continue
			fi
			MKPATH=$(dirname "$PKGTMP/$PKGNAME/$FILE")
			if [ ! -d "$MKPATH" ]; then
				mkdir -p "$MKPATH"
			fi
# newline IFS
FILEGLOB+="$FILE
"
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

if [ "$GROUPPKG" ]; then
	echo GROUP: $GROUPPKG
	do_group_migrate "$GROUPPKG"
else
	for PKGGROUP in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
		do_group_migrate "$PKGGROUP"
	done
fi
rm -rf "$PKGTMP"
