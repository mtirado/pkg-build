#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# the main assumption here is all packages are package.tar.* files in PKGDIR
#-----------------------------------------------------------------------------
set -e
print_usage()
{
	echo "print_usage: PKGPASS=1 pkg-build <pkg-dir> [numjobs]"
}
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	print_usage
	exit 0
fi
if [ "$1" = "" ]; then
	print_usage
	exit -1
fi

# make absolute path
if [[ "$1" != /* ]]; then
	PKGDIR="$(pwd)/$1"
else
	PKGDIR="$1"
fi

# number of parallel jobs for make to use
if [ "$2" = "" ]; then
	JOBS=1
elif test $2 -lt 0; then
	JOBS=1
elif test "$2" -lt 128; then
	JOBS="$2"
else
	exit -1
fi

if [ "$PKGINCLUDE" == "" ]; then
	export PKGINCLUDE="/usr/bin/pkg-include.sh"
fi
if [ "$PKGPREFIX" == "" ]; then
	export PKGPREFIX="/usr"
fi
#-----------------------------------------------------------------------------
#
CWD=$(pwd)
PKGPREPARE="pkg-prepare.sh"
PKGCOMPILE="pkg-compile.sh"
PKGGROUP=$(basename $PKGDIR)
PKGBUILDDIR="$CWD/pkgbuild-$PKGGROUP"
PKGDISTDIR="$PKGBUILDDIR/pkgdist"
export PKGBUILDDIR
export PKGDISTDIR
export PKGDIR
export JOBS

# pass is mandatory for all packages right now, might decide to fallback to 1
# or prompt user to input pass manually if not using PKGAUTOMATE
if [ -z "$PKGPASS" ]; then
	echo "error, set PKGPASS and try again"
	echo "pass is the first column in the wares file"
	print_usage
	exit -1;
fi
echo -n "build pass: "
case "$PKGPASS" in
	1|2|3|4|5|6|7|8|9|A|B|C)
		echo "$PKGPASS"
	;;
	*)
		echo "multipass error, valid pass are numbers 1-9"
		print_usage
		exit -1
	;;
esac

# directory where compilation occurs
if [ ! -e $PKGBUILDDIR ]; then
	mkdir $PKGBUILDDIR
fi

cd $PKGBUILDDIR

# extract packages
$PKGPREPARE $PKGDIR || {
	RETVAL=$?
	case "$RETVAL" in
	1)
		echo "package built."
		exit 1
	;;
	*)
		echo "prep failed"
		exit -1
	;;
	esac
}
echo " prepared."

# parse wares file and run build script
# assumes untarred directory is same as filename without .tar.* extension.
# XXX some source archives from upstream will break. a quick remedy is to just
# rename the archive.tar.* file to match the expected dirname. archives with no
# main subdirectory will not work with this script and should be recreated. =(
while read LINE ;do
	cd $PKGBUILDDIR
	export PKGROOT="$PKGDISTDIR/$(echo $LINE | cut -d " " -f 2)"
	PKGARCHIVE=$(echo $LINE | cut -d " " -f 3)
	PKGARCHIVE=${PKGARCHIVE%.tar.*}
	PKGARCHIVE=$(basename $PKGARCHIVE)
	if [ ! -d "$PKGARCHIVE" ]; then
		echo "archive dir $PKGARCHIVE is missing"
		exit -1
	fi
	# skip completed builds
	if [ -e "$PKGARCHIVE/.pkg-built" ]; then
		continue
	fi

	cd $PKGARCHIVE

	echo "archive dir $PKGARCHIVE"
	export PKGARCHIVE
	mkdir -vp $PKGROOT
	$PKGDIR/$PKGCOMPILE || {
		echo "build failed."
		rm -rf $PKGROOT
		exit -1
	}

	touch ".pkg-built"

done < "$PKGBUILDDIR/wares"


echo "-----------------------------------------------------------------------"
echo " build pass $PKGPASS complete"
echo "-----------------------------------------------------------------------"


