#!/bin/sh

if [ ! "$1" ]; then
    echo "Usage: sudo $0 eth0"
    echo "Where eth0 is the interface providing the internet connection."
    exit 1
fi

# Flush and delete chains
iptables -F
iptables -t nat -F
iptables -t mangle -F

iptables -X
iptables -t nat -X
iptables -t mangle -X

# Enable forwarding
echo "1" > /proc/sys/net/ipv4/ip_forward

# Finally, enable masquerading
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
