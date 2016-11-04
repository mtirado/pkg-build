#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
# repackage into a newly created package group
#-----------------------------------------------------------------------------
set -e

#-----------------------------------------------------------------------------
if [ "$1" = "" ] || [ "$2" = "" ]; then
	echo "usage: pkg-repack pkgname newgroup"
	exit -1
fi

if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi


#-----------------------------------------------------------------------------
PKGNAME="$1"
PKGNAME=$(basename $PKGNAME)
NEWGROUP=$2

if [ -d "$NEWGROUP" ]; then
	echo "new package group $NEWGROUP directory already exists"
fi

#----------- check if package name is in use ---------------------------------
PKGNAME=$(find "$PKGINSTALL/.packages" -name $PKGNAME)
if [ "$PKGNAME" = "" ]; then
	echo "package $PKGNAME not found"
	exit -1
elif [ -d $PKGNAME ]; then
	echo "repacking entire packages group: $PKGNAME"
else
	echo "repacking single package: $PKGNAME"
fi

echo "press any key to repack package(s) from $PKGINSTALL"
read -n 1 -s KEY
mkdir -v $NEWGROUP
echo repacking $PKGNAME...
do_pkgrepack() {
	PKGFILE=$1
	while read FILE; do
		SRCPATH="$PKGINSTALL/$FILE"
		if [ -e "$SRCPATH" ] || [ -L "$SRCPATH" ]; then
			# TODO this uses umask for permissions on new dirs
			# we should instead ensure proper mode gets set
			# on all new directories instead of this.
			NEWFILE="$NEWGROUP/$(basename $PKGFILE)/$FILE"
			if [ -f "$SRCPATH" ] || [ -L "$SRCPATH" ]; then
				mkdir -p $NEWFILE
				rmdir $NEWFILE
				cp -av $SRCPATH $NEWFILE
			elif [ -d "$SRCPATH" ]; then
				mkdir -p $NEWFILE
			else
				echo "unexpected file: $SRCPATH"
				exit -1
			fi
		else
			echo "warning: $SRCPATH did not exist"
			echo "press (c)ontinue or (q)uit"
			read -n 1 -s KEY
			if [ "$KEY" != "c" ] && [ "$KEY" != "C" ]; then
				exit -1
			fi

		fi
	done <$PKGFILE

}

# if it's a file just remove that one package leaf node
if [ -f $PKGNAME ]; then
	do_pkgrepack $PKGNAME
# directories are package groups, remove all package files in group
elif [ -d $PKGNAME ]; then
	cd $PKGNAME
	for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
		do_pkgrepack $ITEM
	done
else
	echo "unexpected file type, or duplicate entries in $PKGINSTALL"
	exit -1
fi


