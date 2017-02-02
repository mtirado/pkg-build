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
PKGNAME=$(basename $PKGNAME)

#----------- check if package name is in use ---------------------------------
PKGNAME=$(find "$PKGINSTALL/.packages" -name "$PKGNAME")
if [ "$PKGNAME" = "" ]; then
	echo "package $PKGNAME not found"
	exit -1
elif [ -d "$PKGNAME" ]; then
	echo "removing all packages in group: $PKGNAME"
else
	echo "removing single package: $PKGNAME"
fi

echo "press any key to remove package(s) from $PKGINSTALL"
read -n 1 -s KEY
echo removing "$PKGNAME..."
#----------- remove files --------------------------------------------
do_pkgremove() {
	PKGFILE=$1
	FILES=$(cat "$PKGFILE")
	for FILE in $FILES; do
		FILEPATH="$PKGINSTALL/$FILE"
		if [ -e "$FILEPATH" ] || [ -L "$FILEPATH" ]; then
			if [ -f "$FILEPATH" ] || [ -L "$FILEPATH" ]; then
				rm -f "$FILEPATH"
			elif [ -d "$FILEPATH" ]; then
				set +e
				rmdir "$FILEPATH"
				if [ "$?" -ne 0 ]; then
					KEY=""
					echo "(c)ontinue anyway?"
					read -n 1 -s KEY
					if [ "$KEY" != "c" ] && [ "$KEY" != "C" ]; then
						exit -1
					fi
				fi
				set -e
			else
				echo "unexpected file: $FILEPATH"
				exit -1
			fi
		else
			echo "warning: $FILEPATH did not exist"
		fi
	done

	#------- remove package file --------------------------------
	rm -f "$PKGFILE"
	echo "package $PKGFILE removed."
}

# if it's a file just remove that one package leaf node
if [ -f "$PKGNAME" ]; then
	do_pkgremove "$PKGNAME"
# directories are package groups, remove all package files in group
elif [ -d "$PKGNAME" ]; then
	cd "$PKGNAME"
	for ITEM in $(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n'); do
		do_pkgremove "$ITEM"
	done
	rmdir -v "$PKGNAME"
else
	echo "unexpected file type, or duplicate entries in $PKGINSTALL"
	exit -1
fi


