#!/bin/sh

FIRST_IP=$(hostname -I | cut -d ' ' -f1)
FIRST_INTERFACE=$(ip link show | grep -v 'lo' | head -n 1 | awk '{print $2}' | sed 's/://g')

ip tuntap add mode tun dev tun0
ip addr add 198.18.0.1/15 dev tun0
ip link set dev tun0 up
ip route del default
ip route add default via 198.18.0.1 dev tun0 metric 1
ip route add default via $FIRST_IP dev $FIRST_INTERFACE metric 10

screen -dmS tun2socks  /home/tun2socks-linux-amd64 -device tun0 -proxy socks5://192.168.100.102:2085 -interface $FIRST_INTERFACE