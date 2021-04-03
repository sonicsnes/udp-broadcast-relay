UDP Broadcast Relay for Linux / FreeBSD / pfSense
==========================

This program listens for packets on a specified UDP broadcast port. When
a packet is received, it sends that packet to all specified interfaces
but the one it came from as though it originated from the original
sender.

The primary purpose of this is to allow devices or game servers on separated
local networks (Ethernet, WLAN, VLAN) that use udp broadcasts to find each
other to do so.

INSTALL
-------

    make
    cp udp-broadcast-relay-redux /some/where

USAGE
-----

```
./udp-broadcast-relay-redux \
    -id id \
    --port <udp-port> \
    --dev eth0 \
    [--dev eth1...] \
    [--multicast 224.0.0.251] \
    [-s <spoof_source_ip>] \
    [-t <overridden_target_ip>]
```

- udp-broadcast-relay-redux must be run as root to be able to create a raw
  socket (necessary) to send packets as though they originated from the
  original sender.
- `id` must be unique number between instances. This is used to set the TTL of
  outgoing packets to determine if a packet is an echo and should be discarded.
- Multicast groups can be joined and relayed with
  `--multicast <group address>`.
- The source address for all packets can be modified with `-s <ip>`. This
  is unusual.
- A special source ip of `-s 1.1.1.1` can be used to set the source ip
  to the address of the outgoing interface.
- A special destination ip of `-t 255.255.255.255` can be used to set the
  overriden target ip to the broadcast address of the outgoing interface.
- `-f` will fork the application to the background.

EXAMPLE
-------

#### mDNS / Multicast DNS (Chromecast Discovery + Bonjour + More)
`./udp-broadcast-relay-redux --id 1 --port 5353 --dev eth0 --dev eth1 --multicast 224.0.0.251 -s 1.1.1.1`

(Chromecast requires broadcasts to originate from an address on its subnet)

#### SSDP (Roku Discovery + More)
`./udp-broadcast-relay-redux --id 1 --port 1900 --dev eth0 --dev eth1 --multicast 239.255.255.250`

#### Lifx Bulb Discovery
`./udp-broadcast-relay-redux --id 1 --port 56700 --dev eth0 --dev eth1`

#### Broadlink IR Emitter Discovery
`./udp-broadcast-relay-redux --id 1 --port 80 --dev eth0 --dev eth1`

#### Warcraft 3 Server Discovery
`./udp-broadcast-relay-redux --id 1 --port 6112 --dev eth0 --dev eth1`

#### Relaying broadcasts between two LANs joined by tun-based VPN
This example is from OpenWRT. Tun-based devices don't forward broadcast packets
 so temporarily rewriting the destination address (and then re-writing it back)
 is necessary.

Router 1 (source):

`./udp-broadcast-relay-redux --id 1 --port 6112 --dev br-lan --dev tun0 -t 10.66.2.13`

(where 10.66.2.13 is the IP of router 2 over the tun0 link)

Router 2 (target):

`./udp-broadcast-relay-redux --id 2 --port 6112 --dev br-lan --dev tun0 -t 255.255.255.255`

Note about firewall rules
---

If you are running udp-broadcast-relay-redux on a router, it can be an easy
way to relay broadcasts between VLANs. However, beware that these broadcasts
will not establish a RELATED firewall relationship between the source and
destination addresses.

This means if you have strict firewall rules, the recipient may not be able
to respond to the broadcaster. For instance, the SSDP protocol involves
sending a broadcast packet to port 1900 to discover devices on the network.
The devices then respond to the broadcast with a unicast packet back to the
original sender. You will need to make sure that your firewall rules allow
these response packets to make it back to the original sender.
