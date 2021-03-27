# corritor, a [Tor](https://www.torproject.org/) traffic whitelisting OpenWRT network
"Force users to use [Tor Browser](https://www.torproject.org/download/download-easy.html.en)".

This is merely an idea by now.

#### Not affiliated with the Tor Project.

So called "transparent proxies" suffer from significant
[issues](https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxyLeaks)
that we want to address. Also, corritor does not run the Tor software.
It looks at the Tor network from the outside.
This is important because there is no need to upgrade the Router firmware
in order to update Tor.

This should become an [OpenWRT](https://openwrt.org/) (wifi) network
configuration that whitelists traffic to and from the Tor network.

Users _cannot_ use Tor Bridges in this network!
Bridges help when Tor is being blocked. Here,
Tor is allowed - only Tor.

## Why?
* advantages over transparent Tor proxies
  * users don't have to trust the router's Tor software. They run Tor themselves
  * never have old and vulnerable Tor versions on the router
  * simple and lightweight
  * users are more likely to use [TorBrowser](https://www.torproject.org/download/download-easy.html.en) which is more secure than tunnel a normal Browsers' traffic thtough Tor

## DONE
### ipset
`ipset_tor.sh` creates or updates an ipset (named torset by default).

### update
This should simply be run weekly by cron:

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
