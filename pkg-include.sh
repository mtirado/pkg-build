#!/bin/sh
# put all ugly boilerplate functions for pkg-compile scripts in here

#create tar archive from a build's destdir
make_tar_without_prefix()
{
	if [ "$1" == "" ]; then
		echo "maketar_noprefix missing PACKAGE_ROOT parameter"
		exit -1
	fi
	echo "make_tar_without_prefix($1)"
	PACKAGE_ROOT="$1"
	cd "$PACKAGE_ROOT"
	tar -cf "$PACKAGE_ROOT/usr.tar" ./*
	find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
}

#create tar archive from a destdir that has subdir from --prefix option, or
make_tar_prefix()
{
	if [ "$1" == "" ]; then
		echo "maketar_prefix missing PACKAGE_ROOT parameter"
		exit -1
	fi
	if [ "$2" == "" ]; then
		echo "maketar_prefix missing PREFIX parameter"
		exit -1
	fi
	PACKAGE_ROOT="$1"
	PREFIX="$2"
	echo "make_tar_prefix($1, $2)"

	cd "$PACKAGE_ROOT/$PREFIX"
	tar -cf "$PACKAGE_ROOT/$PREFIX.tar" ./*
	cd "$PACKAGE_ROOT"
	find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
}
