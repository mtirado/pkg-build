#!/bin/sh
# (c) Michael R. Tirado GPL Version 3 or any later version.
#
# automated jettisoned multipass package builder
#
# depends on jettison compiled with PODROOT_HOME_OVERRIDE
#-----------------------------------------------------------------------------
set -e
if [ "$1" = "" ] || [ "$1" = "-h" ]; then
	echo "usage: pkg-autopod <package-group> [numjobs]"
	exit -1
fi
if [ "$2" = "" ]; then
	JOBS=1
elif test $2 -lt 0; then
	JOBS=1
elif test "$2" -lt 128; then
	JOBS="$2"
else
	exit -1
fi
PKGNAME=$1
# jettison program built with PODROOT_HOME_OVERRIDE
if [ -z "$JETTISON" ]; then
	JETTISON="jettison_autopod"
fi
# autopod config filename to get pod path
if [ -z "$PODCONFIG" ]; then
	PODCONFIG="autopod.pod"
fi
# path to package group directories
if [ -z "$PKGREPO" ]; then
	PKGREPO=/podhome/system-pkgs/pkgs
fi
# installation prefix
if [ -z "$PKGINSTALL" ]; then
	export PKGINSTALL="/usr/local"
fi
export PKGAUTOMATE="auto"
#trap 'echo SIGTERM' SIGTERM

# jettison arguments, TODO add --clear-environ & --init for setting pod environ
JETTISON="$JETTISON /bin/sh $PODCONFIG --blacklist"
#if [ ! -z "$BLACKLIST" ]; then
#	JETARGS="$JETARGS --blacklist"
#fi

# --clear-environ will break this, pass as argument or use file instead
PKGPASS=1
while true; do
	export PKGPASS

	$JETTISON pkg-build.sh $PKGREPO/$PKGNAME $JOBS
	RETVAL=$?
	case "$RETVAL" in
	0)
		echo "pass $PKGPASS completed."
	;;
	1)
		echo "autopod finished."
		exit 0
	;;
	*)
		echo "autopod error"
		exit -1
	;;
	esac

	pkg-install.sh \
		/opt/pods/$USER/$PODCONFIG/podhome/pkgbuild-$PKGNAME/pkgdist \
		$PKGNAME

	# if you need more than 9 passes, we have serious problems.
	# pkg-build also checks this, if you feel compelled to increase limit.
	case "$PKGPASS" in
		1) PKGPASS="2"		;;
		2) PKGPASS="3"		;;
		3) PKGPASS="4"		;;
		4) PKGPASS="5"		;;
		5) PKGPASS="6"		;;
		6) PKGPASS="7"		;;
		7) PKGPASS="8"		;;
		8) PKGPASS="9"		;;
		9) exit 0		;;
		*) echo "multipass error"
			exit -1 	;;
	esac

done


