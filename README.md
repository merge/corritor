# corritor, a Tor traffic whitelisting OpenWRT network

#### Not affiliated with the Tor Project.

The [corridor](https://github.com/rustybird/corridor) Projekt adresses
important issues that "transparently torifying gateways" suffer from. It
still runs the Tor software itself though.

This should become an [OpenWRT](https://openwrt.org/) network configuration
that simply whitelists traffic to and from Guard relays only.

## DONE
### ipset
`torset.sh` creates or updates an ipset named torset.

### update
This should simply be run hourly by cron:

	15 * * * * </path/to/torset.sh>

## TODO
### Hardware
* What constraints do we have? Flashsize? USB Stick?
* see openwrt's [table of hardware](https://openwrt.org/toh/views/toh_available_864)

### iptables
The most simple config... Tor control port, loopback? how will

	vi /etc/firewall.user

look like?

	iptables -t nat -A PREROUTING -i wlan0 -m set ! --match-set torset src -j DROP


### OpenWRT network
We want to apply iptables to the wifi and still be able to use opkg and
whatnot when connected to LAN. Default to an open wifi with a predefined
name (free4Tor ?) is fine.

Global bandwith limit for the wifi!

### Wifi Portal for downloading Tor Browser
* Preferably, manually redirect any "dropped" port 80/443 to a local page.
Would something like this work, when running a [webserver](https://openwrt.org/docs/guide-user/services/webserver/http.uhttpd)?
How to combine with the whitelist? see iptables.

* whitelist torproject.org ? no. avoid allowing DNS.
* gettor email
* https://github.com/TheTorProject/gettorbrowser
* NO, we should have an ip:port with tor browser, we can link to at our local html site!!
