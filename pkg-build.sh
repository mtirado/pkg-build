#!/bin/bash
# (c) Michael R. Tirado GPL Version 3 or any later version.
# export PKGAUTOMATE=1 to skip user interaction
#
# the main assumption here is all packages are package.tar.* files in pkg-dir
#-----------------------------------------------------------------------------
set -e
umask 022

export PKGAUTOMATE="1"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "usage: pkg-build <pkg-dir> [numjobs]"
	exit 0
fi
if [ "$1" = "" ]; then
	echo "usage: pkg-build <pkg-dir> [numjobs]"
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

#-----------------------------------------------------------------------------

CWD=$(pwd)
PKGPREPARE="pkg-prepare.sh"
PKGCOMPILE="pkg-compile.sh"
PKGBUILDDIR="$CWD/pkgbuild-$(basename $PKGDIR)"
PKGDISTDIR="$PKGBUILDDIR/pkgdist"
export PKGBUILDDIR
export PKGDISTDIR
export PKGDIR
export JOBS

echo ""
echo "-----------------------------------------------------------------------"
echo " package directory: $PKGDIR"
echo " parallel jobs: $JOBS"
echo "-----------------------------------------------------------------------"
if [ "$PKGAUTOMATE" != "1" ]; then
	echo "press any key to continue."
	read -n 1 -s KEY
fi


#if [ -e "$PKGBUILDDIR" ]; then
#	echo "build directory $PKGBUILDDIR already exists, remove it."
#	exit -1
#fi

# everything happens in temporary build directory
if [ ! -e $PKGBUILDDIR ]; then
	mkdir $PKGBUILDDIR
fi

cd $PKGBUILDDIR

# extract packages
echo "running prep script..."
$PKGPREPARE $PKGDIR || {
	echo "prep failed"
	exit -1
}
echo "-----------------------------------------------------------------------"
echo " prepared."
echo "-----------------------------------------------------------------------"
if [ "$PKGAUTOMATE" != "1" ]; then
	echo "press any key to continue."
	read -n 1 -s KEY
fi

# configure and build
echo "running build script..."
$PKGDIR/$PKGCOMPILE || {
	echo "build failed"
	exit -1
}

#TODO more informative output on packages installed
echo "-----------------------------------------------------------------------"
echo " built. you can now run pkg-install as root."
echo " pkg-install.sh $PKGDISTDIR "
echo "-----------------------------------------------------------------------"

