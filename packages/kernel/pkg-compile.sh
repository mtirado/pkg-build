#!/bin/sh
set -e
source "$PKGINCLUDE"

KARCH="i386"
ARCHDIR="x86"
KCONFIG="$PKGDIR/linux-x86-config"
KPATCH="$PKGDIR/linux-x86-drm-fix.patch"

case "$PKGARCHIVE" in
	linux-*)
		PKGPREFIX="/"
		make mrproper

		#TODO patch list
		patch -p1 < "$KPATCH"
		cp "$KCONFIG" ./.config

		make "-j$JOBS"

		# notes:
		# if you configure for signed modules don't strip binaries!
		#
		# build may fail during LD module.ko, use -j1 or manually restart
		# and install. there's no good way to do this automatically and
		# i have no idea what is causing the builds to break. when this
		# happens in other packages i set $JOBS in script to 1, but who
		# has time to wait for fat generic kernel build with -j1 ?

		#make headers_install ARCH="$KARCH" INSTALL_HDR_PATH="$PKGROOT/usr"
		make headers_install ARCH="$KARCH" INSTALL_HDR_PATH="$PKGROOT"
		make modules_install INSTALL_MOD_PATH="$PKGROOT"
		mkdir -pv "$PKGROOT/boot"
		cp -v "arch/$ARCHDIR/boot/bzImage" "$PKGROOT/boot/$PKGARCHIVE"
		cp -v "$KCONFIG" "$PKGROOT/boot/$(basename "$KCONFIG")"
		make_tar "$PKGROOT"
	;;
	*)
		echo "unknown archive"
		exit -1
	;;

esac

