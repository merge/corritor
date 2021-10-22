#!/bin/sh

set -e

setname=torset

usage()
{
	echo "                  corritor"
	echo "                  --------"
	echo "This script sets up network forwarding if the destination is part"
	echo "of the Tor network"
	echo ""
	echo "Usage: $0 [-s <ipset_name>]"
}

args=$(getopt -o s: -- "$@")
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

# if return is > 0 the ipset does not exist
# iptables -C INPUT -m set --match-set sshd src -j DROP

iptables -w -N CORRITOR_FILTER
iptables -w -A CORRITOR_FILTER -m conntrack --ctstate ESTABLISHED,RELATED       -j RETURN
iptables -w -A CORRITOR_FILTER -m set --match-set $setname dst,dst -j RETURN
iptables -w -A CORRITOR_FILTER -j REJECT --reject-with icmp-host-prohibited
iptables -w -I FORWARD -j CORRITOR_FILTER

sysctl net.ipv4.ip_forward=1                                                    

if [ -e /proc/sys/net/ipv6/conf/all/forwarding ] ; then
        sysctl net.ipv6.conf.all.forwarding=0
fi

# iptables -w -t nat -N CORRITOR_NAT
# iptables -w -t nat -I POSTROUTING -j CORRITOR_NAT
# iptables -w -t nat -I CORRITOR_NAT -s "192.168.0.1" ! -d "192.168.0.1" -j MASQUERADE
