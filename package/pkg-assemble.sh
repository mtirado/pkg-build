#!/bin/bash
# assumes untarred directory is same as filename without .tar.* extension.
set -e
umask 022
read -r LINE<wares
ARCHIVEDIR=${LINE%.tar.*}
cd $ARCHIVEDIR
echo "$ARCHIVEDIR/make -j$JOBS"

make install

