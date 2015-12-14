#!/bin/bash
set -e
INSTALL="/podhome/local"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "usage: pkg-build <src-dir> <pkg-dir> [numjobs]"
	exit 0

#-----------------------------------------------------------------------------
#src-dir should be the source code directory where configure file is located
if [ "$1" = "" ]; then
	echo "usage: pkg-build <src-dir> <pkg-dir> [numjobs]"
	exit -1
fi
#pkg-dir is the --prefix path where we build into
if [ "$2" = "" ]; then
	echo "usage: pkg-build <src-dir> <pkg-dir> [numjobs]"
	exit -1
fi

# make absolute path
if [[ "$2" != /* ]]; then
	PKGDIR="$(pwd)/$2"
else
	PKGDIR="$2"
fi

# number of parallel jobs for make to use
if [[ "$3" -eq "" ]]; then
	JOBS=1
elif test $3 -lt 0; then
	JOBS=1
elif test "$3" -lt 32; then
	JOBS="$3"
else
	exit -1
fi
#-----------------------------------------------------------------------------



echo ""
echo "source directory: $1"
echo "package directory: $PKGDIR"
echo "make -j$JOBS"
echo ""
echo "press any key to continue"
read -n 1 -s KEY
echo "rm -rf $PKGDIR..."
rm -rf $PKGDIR
mkdir $PKGDIR


cd $1
echo "cleaning..."
sleep 1
make clean

# TODO  -- modularize configuration script
echo "configuring..."
./configure 						\
	       	--prefix=$PKGDIR			\
		--target-list=i386-linux-user
#		--enable-seccomp			\
echo ""
echo "configured, starting build..."
echo "in 3"
sleep 1
echo "in 2"
sleep 1
echo "in 1"
sleep 1
echo "in 0"
sleep 1

make -j$JOBS && make install

echo ""
echo "you can remove any undesired files from $PKGDIR at this time."
echo "then run 'pkg-install $PKGDIR <name>' as owner of $INSTALL"


