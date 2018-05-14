#!/bin/sh
# FIXME this is totally dumb and can only work from this directory
set -e

ipset create -exist torset hash:ip,port
./torset_add_auths.sh
./torset_add_fbdirs.sh
if [ ! -e ./consensus ] ; then
	./download_consensus.sh
fi
./torset_add_guards.sh
