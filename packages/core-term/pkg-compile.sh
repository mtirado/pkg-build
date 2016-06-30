#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '
# assumes ncurses install prefix will be /usr
CURSES_PREFIX=/usr
export PKG_CONFIG_PATH="/usr/lib/pkgconfig"
while read LINE ;do
	cd $CWD
	PKGROOT=$PKGDISTDIR/$(echo $LINE | cut -d " " -f 1)
	ARCHIVEDIR=$(echo $LINE | cut -d " " -f 2)
	ARCHIVEDIR=${ARCHIVEDIR%.tar.*}
	if [ ! -d "$ARCHIVEDIR" ]; then
		echo "archive dir $ARCHIVEDIR is missing"
		exit -1
	fi

	cd $ARCHIVEDIR
	echo "archive dir $ARCHIVEDIR"
	echo "pkg dir $PKGDIR"
	case "$ARCHIVEDIR" in
		ncurses*)
			DESTDIR=$PKGROOT				\
			./configure 					\
				--prefix=$CURSES_PREFIX			\
				--with-shared				\
				--without-debug				\
				--without-normal			\
				#--enable-pc-files

			export CPPFLAGS="-I$PKGROOT/include -I$PKGROOT/include"
			export LDFLAGS="-L$PKGROOT/lib -L$PKGROOT/lib"

		;;
		ex-*)
			sed -i "s|DESTDIR.*=|DESTDIR = $PKGROOT|" Makefile
			sed -i "s|/usr/ucb|/usr/bin|" Makefile
			sed -i "s|/usr/local|/|" Makefile
			sed -i "s|= termlib|= ncurses|" Makefile

		;;
		procps*)
			./configure 			\
				--prefix=$PKGROOT	\
				--disable-kill
		;;
		#*)
		#	./configure 			\
		#		--prefix=$PKGROOT

	esac

	make -j$JOBS
	make install

	case "$ARCHIVEDIR" in
		# move files from /usr to / in pkgroot maybe ncurses should be
		# it's own package instead of hacking around hacks
		ncurses*)
			cp -fva $PKGROOT/$CURSES_PREFIX/* $PKGROOT/
			rm -rfv $PKGROOT/$CURSES_PREFIX
		;;
	esac

	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKGROOT/lib/pkgconfig"

done < $PKGDIR/wares

