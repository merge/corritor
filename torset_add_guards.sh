#!/bin/sh
set -e

have_setname=0
verbose=0

usage()
{
	echo "Usage: $0 -s <ipset_name> [-v]"
}

args=$(getopt -o s:hv -- "$@")
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
	-v)
		verbose=1
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

if [ ! -e external/consensus ] ; then
	if [ ! -e external/auth_dirs.inc ] ; then
		echo "Directory authorities file missing"
		exit 1
	fi

	if [ $verbose -gt 0 ] ; then
		echo "downloading consensus file. please wait."
	fi
	cd external && cat auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | while read entry; do curl --silent -L -O $entry/tor/status-vote/current/consensus && break ; done
	cd ..
fi

cat external/consensus | grep -B 2 Guard | grep -o '[0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\ [0-9]\{1,5\}' | tr ' ' ',' | while read entry; do ipset add -exist ${SETNAME} $entry; done
