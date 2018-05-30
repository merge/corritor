# corritor, a Tor traffic whitelisting OpenWRT network

#### Not affiliated with the Tor Project.

[corridor](https://github.com/rustybird/corridor), a different but similar
project, adresses important issues that "transparently torifying gateways"
suffer from.
It still runs the Tor software itself though. Here, we don't.

This should become an [OpenWRT](https://openwrt.org/) (wifi) network
configuration that whitelists traffic to and from the Tor network.

You _cannot_ use Tor Bridges in this network!
They help you when Tor is being blocked. Here,
Tor is allowed - only Tor.

## Why?
* advantages over transparent Tor routers
  * users don't have to trust the router's Tor software. They run Tor themselves
  * never have old and vulnerable Tor versions on the router
  * simple and lightweight
  * users are more likely to use TorBrowser

## DONE
### ipset
`ipset_tor.sh` creates or updates an ipset named torset.

### update
This should simply be run hourly by cron:

	15 * * * * </path/to/ipset_tor.sh>

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
* only on the wlan interface. Full internet on the lan interfaces
* pre-defined wifi name "free4Tor" is fine
* [Global bandwith limit](https://openwrt.org/docs/guide-user/network/traffic-shaping/qos-tomerge#quick_start_guide)

### Wifi Portal for downloading Tor Browser
* we have IP addresses that mirror torproject.org in mirrors.txt
* redirection of port 80, before dropping, would be nice
