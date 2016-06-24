#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
IFS=' '

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
			./configure 			\
				--prefix=$PKGROOT	\
				--with-shared		\
				--without-debug
			# procps-ng build system is a bit flaky without pkg-config
			export CFLAGS="-I$PKGROOT/include -I$PKGROOT/include/ncurses"
			export LDFLAGS="-L$PKGROOT/lib -L$PKGROOT/lib/ncurses"
			export NCURSES_LIBS="-L$PKGROOT/lib -lncurses"
			export NCURSES_CFLAGS="-I$PKGROOT/include/ncurses"
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

	#post install case can go here if needed
	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKGROOT/lib/pkgconfig"

done < $PKGDIR/wares

