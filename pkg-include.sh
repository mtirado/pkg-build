#!/bin/sh
# put all ugly boilerplate functions for pkg-compile scripts in here
# TODO sanitize paths

export PKGBUILD_MAKE_FLAGS="-output-sync=target"

make_tar_root()
{
	PACKAGE_ROOT="$1"
	cd "$PACKAGE_ROOT"
	mkdir -p "usr"
	# try to abide by FHS, keep root clean and documentation in the right place
	for SUBDIR in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
		if [ "$SUBDIR" != "boot" ]			\
				&& [ "$SUBDIR" != "bin" ]	\
				&& [ "$SUBDIR" != "sbin" ]	\
				&& [ "$SUBDIR" != "usr" ]	\
				&& [ "$SUBDIR" != "lib" ]	\
				&& [ "$SUBDIR" != "etc" ]; then
				#&& [ "$SUBDIR" != "libexec" ]; then
			mv  "$SUBDIR" ./usr
		fi
	done

	tar -cf "$PACKAGE_ROOT/root.tar" ./*
	find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
}


make_tar_root_flatten_subdirs()
{
	PACKAGE_ROOT="$1"
	# tar each subdir
	# yes this looks crazy, but it preserves hard links.
	cd "$PACKAGE_ROOT"
	for SUBDIR in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
		cd "$SUBDIR"
		tar -cf "$PACKAGE_ROOT/$SUBDIR.tar" ./*
		cd "$PACKAGE_ROOT"
		rm -r "$SUBDIR"
	done

	# untar subdirs
	cd "$PACKAGE_ROOT"
	for TAR in $(find . -type f -iname '*.tar' -printf '%f\n'); do
		echo "untarring $TAR"
		tar xfv "$TAR"
		rm "$TAR"
	done

	make_tar_root "$PACKAGE_ROOT"
}

# create tar archive from a build's destdir
make_tar()
{
	if [ "$1" == "" ]; then
		echo "maketar_noprefix missing PACKAGE_ROOT parameter"
		exit -1
	fi
	PACKAGE_ROOT="$1"
	if [ "$PKGPREFIX" == "/" ]; then
		make_tar_root $1
		return $?
	else
		PREFIX="$PKGPREFIX"
	fi

	cd "$PACKAGE_ROOT"
	tar -cf "$PACKAGE_ROOT/$PREFIX.tar" ./*
	find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
}



# move subdirectories to archives root
make_tar_flatten_subdirs()
{
	if [ "$1" == "" ]; then
		echo "maketar_prefix missing PACKAGE_ROOT parameter"
		exit -1
	fi
	if [ "$PKGPREFIX" == "" ]; then
		echo "maketar_prefix missing PKGPREFIX env var"
		exit -1
	fi
	PACKAGE_ROOT="$1"
	PREFIX="$PKGPREFIX"
	if [ "$PKGPREFIX" == "/" ]; then
		make_tar_root_flatten_subdirs $1
		return $?
	else
		ls -lah "$PACKAGE_ROOT"
		PREFIX="$PKGPREFIX"
	fi

	cd "$PACKAGE_ROOT"
	if [ -e "$PACKAGE_ROOT/$PREFIX.tar" ]; then
		rm "$PACKAGE_ROOT/$PREFIX.tar"
	fi

	for SUBDIR in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
		cd "$SUBDIR"
		tar -rf "$PACKAGE_ROOT/$PREFIX.tar" ./*
		cd "$PACKAGE_ROOT"
		rm -r "$SUBDIR"
	done
}
