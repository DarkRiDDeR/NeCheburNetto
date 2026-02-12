#!/bin/sh

PROXY_IP="192.168.100.102"
PROXY_PORT="2085"
TUN_ADDR="198.18.0.1/32"

FIRST_INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -n1)
GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' | head -n1)

ip tuntap add mode tun dev tun0
ip addr add $TUN_ADDR dev tun0
ip link set dev tun0 up
ip link set dev tun0 mtu 1400

ip route del default
ip route add default dev tun0 metric 1
ip route add $PROXY_IP/32 via $GATEWAY_IP dev $FIRST_INTERFACE
ip route append default via $GATEWAY_IP dev $FIRST_INTERFACE metric 10

sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.default.rp_filter=0
sysctl -w net.ipv4.conf.$FIRST_INTERFACE.rp_filter=0

screen -dmS tun2socks /home/tun2socks-linux-amd64 \
    -device tun0 \
    -proxy socks5://$PROXY_IP:$PROXY_PORT \
    -interface $FIRST_INTERFACE