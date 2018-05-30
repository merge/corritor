#!/bin/sh
set -e

have_setname=0

usage()
{
	echo "Usage: $0 -s <ipset_name>"
}

args=$(getopt -o s:h -- "$@")
if [ $? -ne 0 ] ; then
	usage
	exit 1
fi

eval set -- "$args"
while [ $# -gt 0 ]
do
	case "$1" in
	-s)
		SETNAME=$2
		have_setname=1
		shift
		;;
	-h)
		usage
		exit 1
		;;
	--)
		shift
		break
		;;
	*)
		echo "Invalid option: $1"
		exit 1
		;;
	esac
	shift
done


if [ ! "$have_setname" -gt 0 ] ; then
	echo "no ipset name"
	usage
	exit 1
fi

if [ ! -e ./external/auth_dirs.inc ] ; then
	mkdir -p external && cd external && curl --silent -L -O https://gitweb.torproject.org/tor.git/plain/src/or/auth_dirs.inc
	cd ..
fi

cat external/auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist ${SETNAME} $entry; done
