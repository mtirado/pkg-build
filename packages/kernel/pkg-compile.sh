#!/bin/sh
set -e
source "$PKGINCLUDE"

KARCH="i386"
ARCHDIR="x86"
KCONFIG="$_PKG_DIR/linux-x86-config"
KPATCH="$_PKG_DIR/linux-x86-drm-fix.patch"

case "$PKGARCHIVE" in
linux-*)
	case "$PKG" in
	linux-headers)
		make mrproper
		make headers_install ARCH="$KARCH" INSTALL_HDR_PATH="$PKGROOT/usr"
		#make_tar_flatten_subdirs "$PKGROOT"
		make_tar "$PKGROOT"
		exit 0
	;;
	linux)
		PKGPREFIX="/"
	if [ "$PKGNOCONF" == "" ]; then
		make mrproper

		#TODO patch list
		patch -p1 < "$KPATCH"
		# C#3
		sed -i 's/DEFAULT_BELL_PITCH.*750/DEFAULT_BELL_PITCH 277/' \
			drivers/tty/vt/vt.c

		cp -v "$KCONFIG" ./.config
		# notice new config options
		make oldconfig
	fi

		make "-j$JOBS"

		# notes:
		# if you configure for signed modules don't strip debug info!
		#
		# build may fail during LD module.ko, use -j1 or manually restart
		# and install. there's no good way to do this automatically and
		# i have no idea what is causing `make` file io error. when this
		# happens in other packages i set $JOBS in script to 1, but who
		# has time to wait for fat generic kernel build with -j1 ?

		make modules_install INSTALL_MOD_PATH="$PKGROOT"
		mkdir -pv "$PKGROOT/boot"
		cp -v "arch/$ARCHDIR/boot/bzImage" "$PKGROOT/boot/$PKGARCHIVE"
		cp -v "$KCONFIG" "$PKGROOT/boot/$(basename "$KCONFIG")"
		# what are these files hanging around for?
		find -name '*.install*' -exec rm ./{} \;
		make_tar "$PKGROOT"
		exit 0
	;;
	esac
;;
esac
echo "unknown package"
exit -1
