#!/bin/sh
set -e

setname=torset

tmpsetname=${setname}-tmp
ipset create ${tmpsetname} hash:ip,port
./torset_add_auths.sh -s ${tmpsetname}
./torset_add_fbdirs.sh -s ${tmpsetname}
./torset_add_guards.sh -s ${tmpsetname}

ipset create -exist ${setname} hash:ip,port
ipset swap ${tmpsetname} ${setname}
ipset destroy ${tmpsetname}

entries=$(ipset list ${setname} | wc -l)
echo "ipset ${setname} updated. ${entries} entries."
