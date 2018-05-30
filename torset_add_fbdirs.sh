#!/bin/sh
set -e

have_setname=0
have_workdir=0

usage()
{
	echo "Usage: $0 -s <ipset_name> -d <workdir>"
}

args=$(getopt -o d:s:h -- "$@")
if [ $? -ne 0 ] ; then
	usage
	exit 1
fi

eval set -- "$args"
while [ $# -gt 0 ]
do
	case "$1" in
	-d)
		WORKDIR=$2
		have_workdir=1
		shift
		;;
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

if [ ! "$have_workdir" -gt 0 ] ; then
	echo "no working directory given"
	usage
	exit 1
fi

if [ ! "$have_setname" -gt 0 ] ; then
	echo "no ipset name"
	usage
	exit 1
fi

cd ${WORKDIR}

if [ ! -e fallback_dirs.inc ] ; then
	curl --silent -L -O https://gitweb.torproject.org/tor.git/plain/src/or/fallback_dirs.inc
fi

cat fallback_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist ${SETNAME} $entry; done
