# corritor, a Tor traffic whitelisting OpenWRT network

#### Not affiliated with the Tor Project.

The [corridor](https://github.com/rustybird/corridor) Projekt adresses
important issues that "transparently torifying gateways" suffer from. It
still runs the Tor software itself though.

This should become an [OpenWRT](https://openwrt.org/) network configuration that simply whitelists
traffic to and from Guard relays only.

We have to whitelist about 2000 ip:port combinations and drop everything else.

## TODO
### consensus source
We need to hourly fetch a consesus file. Do we have to use a Network Authority?
See https://consensus-health.torproject.org/
### iptables and ipset
This uses a consensus file, parses for servers with Guard flag, refactors
for `ipset` and runs `ipset add` on each server in the list:

		ipset create guardset
		cat consensus | grep -B 2 Guard | grep -o '[0-9]\{2,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\ [0-9]\{1,5\}' | tr ' ' ',' | while read entry; do ipset add guardset $entry; done

To enable it:

		iptables -A INPUT -m set ! --match-set guardset src -j DROP
		iptables -A OUTPUT -m set ! --match-set guardset src -j DROP

### update
Procedure: https://wiki.gentoo.org/wiki/IPSet

Guards are quite stable, update every few hours?

### OpenWRT network
We want to apply iptables to the wifi and still be able to use opkg and
whatnot when connected to LAN. Default to an open wifi with a predefined
name (free4Tor ?) is fine.

Global bandwith limit for the wifi!

### Wifi Portal for downloading Tor Browser
* Preferably, manually redirect any "dropped" port 80/443 to a local page.
Would something like this work, when running a [webserver](https://openwrt.org/docs/guide-user/services/webserver/http.uhttpd)?
How to combine with the whitelist?:

		iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 127.0.0.1:80
		iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:443

* whitelist torproject.org ?
* [gettor](https://www.torproject.org/projects/gettor) ?

### Hardware
* What constraints do we have? Flashsize?
* see openwrt's [table of hardware](https://openwrt.org/toh/views/toh_available_864)
