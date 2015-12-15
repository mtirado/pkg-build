#!/bin/bash
#
# export PKGAUTOMATE=1 to skip user interaction
#
#-----------------------------------------------------------------------------
set -e
umask 022
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
elif test "$2" -lt 32; then
	JOBS="$2"
else
	exit -1
fi
#-----------------------------------------------------------------------------


PKGNAME="pkgdist-$(basename $PKGDIR)"
PKGCONFIG="pkg-configure.sh"
PKGCOMPILE="pkg-compile.sh"
PKGASSEMBLE="pkg-assemble.sh"
PKGDISTDIR="$PKGDIR/$PKGNAME"

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



# everything happens in package directory
#mkdir $PKGDISTDIR
cd $PKGDIR


echo "running config script..."
./$PKGCONFIG
echo "-----------------------------------------------------------------------"
echo " configured."
echo "-----------------------------------------------------------------------"
if [ "$PKGAUTOMATE" != "1" ]; then
	echo "press any key to continue."
	read -n 1 -s KEY
fi


echo "running build script..."
./$PKGCOMPILE
echo "-----------------------------------------------------------------------"
echo " build finished."
echo "-----------------------------------------------------------------------"
if [ "$PKGAUTOMATE" != "1" ]; then
	echo "press any key to continue."
	read -n 1 -s KEY
fi


echo "running assembly script..."
./$PKGASSEMBLE
echo "-----------------------------------------------------------------------"
echo " assembly complete, ready for pkg-install."
echo "-----------------------------------------------------------------------"
if [ "$PKGAUTOMATE" != "1" ]; then
	echo "press any key to continue."
	read -n 1 -s KEY
fi




