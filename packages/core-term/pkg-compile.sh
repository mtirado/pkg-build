#!/bin/sh
# assumes untarred directory is same as filename without .tar.* extension.
set -e
CWD=$(pwd)
#ugh procps configure is a bit funky
export CFLAGS="-I$PKGDISTDIR/include -I$PKGDISTDIR/include/ncurses"
export LDFLAGS="-L$PKGDISTDIR/lib -L$PKGDISTDIR/lib/ncurses"
while read LINE ;do
	cd $CWD
	ARCHIVEDIR=${LINE%.tar.*}
	if [ ! -d "$ARCHIVEDIR" ]; then
		echo "archive dir $ARCHIVEDIR is missing"
		exit -1
	fi

	cd $ARCHIVEDIR
	echo "archive dir $ARCHIVEDIR"
	case "$ARCHIVEDIR" in
		ncurses*)
			./configure 			\
				--prefix=$PKGDISTDIR	\
				--with-shared		\
				--without-debug
		;;
		ex-*)
			sed -i "s|DESTDIR.*=|DESTDIR = $PKGDISTDIR|" Makefile
			sed -i "s|/usr/ucb|/usr/bin|" Makefile
			sed -i "s|/usr/local|/|" Makefile
			sed -i "s|= termlib|= ncurses|" Makefile
		;;
		procps*)
			NCURSES_LIBS="-L$PKGDISTDIR/lib -lncurses"	\
			NCURSES_CFLAGS="-I$PKGDISTDIR/include/ncurses"	\
			./configure 					\
				--prefix=$PKGDISTDIR			\
				--disable-kill
		;;
		#*)
		#	./configure 				\
		#		--prefix=$PKGDISTDIR
	esac

	make -j$JOBS
	make install

	#post install case can go here if needed

done < $PKGDIR/wares

