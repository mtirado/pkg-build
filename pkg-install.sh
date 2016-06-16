#!/bin/bash
#PKGINSTALL="/podhome/local"
#PKGFILES="/podhome/local/.packages"
umask 022
set -e
#-----------------------------------------------------------------------------
# pkgbuild-dir is the distribution folder normally set by ./configure --prefix
# which is populated on make install
#-----------------------------------------------------------------------------
if [ "$1" = "" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkgname>"
	echo "set PKGINSTALL=<path> to install to other directories"
	exit -1
fi
if [ "$2" = "" ]; then
	echo "usage: pkg-install <pkgdist-dir> <pkgname>"
	echo "set PKGINSTALL=<path> to install to other directories"
	exit -1
fi

if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi

PKGFILES="$PKGINSTALL/.packages"

#-----------------------------------------------------------------------------

PKGDIR="$1"
PKGNAME="$2"
DISTDIR="$PKGDIR"
CWD=$(pwd)

echo "installing package $PKGDIR to $PKGINSTALL"
echo "press any key to continue"
read -n 1 -s KEY
#---------- create pkgs directory if needed ----------------------------------
if [ ! -d "$PKGFILES" ]; then
	mkdir $PKGFILES
fi


#----------- check if package name is in use ---------------------------------
FIND=$(find $PKGFILES -name $PKGNAME)
if [ "$FIND" != "" ]; then
	echo "package $PKGNAME already exists, run pkg-remove first."
	exit -1
fi


#----------- fail if file exists ---------------------------------------------
cd $DISTDIR
EXISTS=0
EXCEPT=0
# TODO check used files in another pass before creating dirs
find . -print0 | (
	while IFS= read -r -d '' FILE
	do
		if [ ! -d "$FILE" ]; then
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "$PKGINSTALL/$FILE already exists"
				EXISTS=$((EXISTS + 1))
				EXCEPT=1
			elif [ "$EXCEPT" = "0" ]; then
				MKPATH=$(dirname "$PKGINSTALL/$FILE")
				if [ ! -e "$MKPATH" ]; then
					echo "make path: $MKPATH"
					mkdir -p "$MKPATH"
				fi
			fi
		else
			if [ -e "$PKGINSTALL/$FILE" ]; then
				echo "make path: $PKGINSTALL/$FILE"
				mkdir -p "$PKGINSTALL/$FILE"
			fi
		fi
	done
	if [ "$EXISTS" != "0" ]; then
		echo "error: $EXISTS file(s) already exist in $PKGINSTALL"
		# TODO we should scan packages to find which one owns file
		exit -1
	fi
)


#----------- construct package file list -------------------------------------
touch $PKGFILES/$PKGNAME
find . -print0 | while IFS= read -r -d '' FILE; do
	if [ ! -d "$FILE" ]; then
		echo $FILE >> $PKGFILES/$PKGNAME
	fi
done
cd $CWD
cd $DISTDIR


#----------- copy files to install destination  ------------------------------
find . -type f -print0 | while IFS= read -r -d '' FILE; do
	cp -rv $FILE $PKGINSTALL/$FILE
done


#----------- copy symlinks to install destination  ------------------------------
find . -type l -print0 | while IFS= read -r -d '' FILE; do
	cp -rv $FILE $PKGINSTALL/$FILE
done


#-- TODO some way to chown, prompt for set caps, suid/gid bit, etc --




