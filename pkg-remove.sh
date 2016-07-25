#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#-----------------------------------------------------------------------------
set -e

#-----------------------------------------------------------------------------
if [ "$1" = "" ]; then
	echo "usage: pkg-remove name"
	exit -1
fi

if [ "$PKGINSTALL" = "" ]; then
	PKGINSTALL="/usr/local"
fi

#-----------------------------------------------------------------------------
PKGNAME="$1"

#----------- check if package name is in use ---------------------------------
PKGNAME=$(find "$PKGINSTALL/.packages" -name $PKGNAME)
if [ "$PKGNAME" = "" ]; then
	echo "package $PKGNAME not found"
	exit -1
fi

echo "removing package from $PKGINSTALL"
echo "press any key to continue"
read -n 1 -s KEY
#---- TODO remove package directories if empty, otherwise error ------
#---- user could either continue deleting, or quit and manually repair
#---- we will need to update the package file to resume after repair!
#-  if every lib is symlinked we could use a manager to swap global version
#-  numbers if we handle -L files seperately, pkg-link.sh or somethin.
#----------- remove files --------------------------------------------
do_pkgremove() {
	PKGFILE=$1
	while read FILE; do
		FILEPATH="$PKGINSTALL/$FILE"
		if [ -e "$FILEPATH" ] || [ -L "$FILEPATH" ]; then
			if [ -f "$FILEPATH" ] || [ -L "$FILEPATH" ]; then
				rm "$FILEPATH"
			elif [ -d "$FILEPATH" ]; then
				rmdir "$FILEPATH"
			else
				echo "unexpected file: $FILEPATH"
				exit -1
			fi
		else
			echo "warning: $FILEPATH did not exist"
		fi
	done <$PKGFILE

	#------- remove package file --------------------------------
	rm $PKGFILE
	echo "package $PKGFILE removed."
}

# if it's a file just remove that one package leaf node
if [ -f $PKGNAME ]; then
	do_pkgremove $PKGNAME
# directories are package groups, remove all package files in group
elif [ -d $PKGNAME ]; then
	cd $PKGNAME
	for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
		do_pkgremove $ITEM
	done
	rmdir -v $PKGNAME
else
	echo "unexpected file, or duplicate entries type in $PKGINSTALL"
	exit -1
fi


