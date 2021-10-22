# corritor, a [Tor](https://www.torproject.org/) traffic whitelisting OpenWRT network
"Force users to use [Tor Browser](https://www.torproject.org/download/download-easy.html.en)".

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
  * users are more likely to use [TorBrowser](https://www.torproject.org/download/download-easy.html.en)
    which is more secure than tunnel a normal Browsers' traffic through Tor

## how to use
`ipset_tor.sh` creates or updates an ipset (named torset by default). This
should be run regularly by cron:

	15 * * * * </path/to/ipset_tor.sh>

`corritor_start.sh` sets up the forwarding filter using iptables, so this
should be run during startup.

### Hardware
* Reference hardware for prototyping: [Netgear Nighthawk X4S](https://openwrt.org/toh/netgear/r7800)
* What constraints do we really have? Flashsize? USB Stick?
* see openwrt's [table of hardware](https://openwrt.org/toh/views/toh_available_864)
