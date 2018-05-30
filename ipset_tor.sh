#!/bin/sh
set -e

setname=torset
verbose=0
workdir=external
keep=0
addfile=""

usage()
{
	echo "			corritor"
	echo "			--------"
	echo "Usage: $0 [-s <ipset_name>] [-v] [-d <workdir>] [-k] [-a file]"
	echo ""
	echo "-h		display this help text and exit"
	echo "-v		verbose output"
	echo "-s		name of the ipset to be created or updated"
	echo "			default: torset"
	echo "-d		directory for downloading files."
	echo "			will be created if not existing"
	echo "			default: external"
	echo "-k		keep the downloads after finishing"
	echo "-a		file with ip:port list to allow too"
}

args=$(getopt -o s:d:khva: -- "$@")
if [ $? -ne 0 ] ; then
	usage
	exit 1
fi

eval set -- "$args"
while [ $# -gt 0 ]
do
	case "$1" in
	-a)
		addfile=$2
		shift
		;;
	-s)
		setname=$2
		shift
		;;
	-d)
		workdir=$2
		shift
		;;
	-k)
		keep=1
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

mkdir -p ${workdir}

tmpsetname=${setname}-tmp

if [ ! -z $addfile ] ; then
	cp ${addfile} ${workdir}/
fi

cd ${workdir}

# dir auths
if [ ! -e auth_dirs.inc ] ; then
	curl --silent -L -O https://gitweb.torproject.org/tor.git/plain/src/or/auth_dirs.inc
fi

ipset create -exist ${tmpsetname} hash:ip,port

cat auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist ${tmpsetname} $entry; done
if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${tmpsetname} | wc -l)
	echo "dir auths added to ${setname}. now ${entries} entries."
fi

# fallback dirs
if [ ! -e fallback_dirs.inc ] ; then
	curl --silent -L -O https://gitweb.torproject.org/tor.git/plain/src/or/fallback_dirs.inc
fi

cat fallback_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist ${tmpsetname} $entry; done
if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${tmpsetname} | wc -l)
	echo "fallback dirs added to ${setname}. now ${entries} entries."
fi

# valid guards (from dir auth)
if [ ! -e consensus ] ; then
	if [ $verbose -gt 0 ] ; then
		echo "downloading consensus file. please wait."
	fi
	cat auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | while read entry; do curl --silent -L -O $entry/tor/status-vote/current/consensus && break ; done
fi

cat consensus | grep -B 2 Guard | grep -B 2 Valid | grep -o '[0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\ [0-9]\{1,5\}' | tr ' ' ',' | while read entry; do ipset add -exist ${tmpsetname} $entry; done
cat consensus | grep -B 2 Authority | grep -o '[0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\ [0-9]\{1,5\}' | tr ' ' ',' | while read entry; do ipset add -exist ${tmpsetname} $entry; done

# custom additions
if [ ! -z $addfile ] ; then
	cat $addfile | grep -o '[0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist ${tmpsetname} $entry; done
fi

ipset create -exist ${setname} hash:ip,port
ipset swap ${tmpsetname} ${setname}
ipset destroy ${tmpsetname}

if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${setname} | wc -l)
	echo "ipset ${setname} fully updated. ${entries} entries."
fi

if [ ! $keep -gt 0 ] ; then
	cd -
	rm -rf ${workdir}
fi
