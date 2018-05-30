#!/bin/sh
set -e

setname=torset
verbose=0
workdir=external
keep=0

usage()
{
	echo "Usage: $0 [-s <ipset_name>] [-v] [-d <workdir>] [-k]"
	echo ""
	echo "-v		verbose output"
	echo "-k		keep the workdir"
}

args=$(getopt -o s:d:khv -- "$@")
if [ $? -ne 0 ] ; then
	usage
	exit 1
fi

eval set -- "$args"
while [ $# -gt 0 ]
do
	case "$1" in
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
ipset create ${tmpsetname} hash:ip,port

./torset_add_auths.sh -s ${tmpsetname} -d ${workdir}
if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${tmpsetname} | wc -l)
	echo "dir auths added to ${setname}. now ${entries} entries."
fi

./torset_add_fbdirs.sh -s ${tmpsetname} -d ${workdir}
if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${tmpsetname} | wc -l)
	echo "fallback dirs added to ${setname}. now ${entries} entries."
fi

if [ $verbose -gt 0 ] ; then
	./torset_add_guards.sh -s ${tmpsetname} -v -d ${workdir}
else
	./torset_add_guards.sh -s ${tmpsetname} -d ${workdir}
fi

ipset create -exist ${setname} hash:ip,port
ipset swap ${tmpsetname} ${setname}
ipset destroy ${tmpsetname}

if [ $verbose -gt 0 ] ; then
	entries=$(ipset list ${setname} | wc -l)
	echo "ipset ${setname} fully updated. ${entries} entries."
fi

if [ ! $keep -gt 0 ] ; then
	rm -rf ${workdir}
fi
