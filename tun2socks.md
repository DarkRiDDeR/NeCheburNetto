# Proxying all traffic via socks5 using tun2socks (Linux)

## tun2socks

A tunnel interface for HTTP and SOCKS proxies on Linux, Android, macOS, iOS and Windows.

Detail https://github.com/tun2proxy/tun2proxy

## Recipe

### external IP address

```bash
curl ipinfo.io/ip
```

### download and unzip tun2socks

install it in the common home root directory

```bash
cd /home/
sudo wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.6.0/tun2socks-linux-amd64.zip
sudo unzip tun2socks-linux-amd64.zip
```

see https://github.com/xjasonlyu/tun2socks/releases/


## tun2socks.sh

create a startup and configuration script for the first network interface

```bash
sudo nano tun2socks.sh
```

code (https://raw.githubusercontent.com/DarkRiDDeR/NeCheburNetto/refs/heads/main/tun2socks.sh):

**Don't forget to specify the IP and port of your server with socks5. Replace 192.168.100.102:2085**

```sh
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
```

### run and check ip

```bash
sudo chmod +x tun2socks.sh
sudo sh tun2socks.sh
curl ipinfo.io/ip
```

Your ip become the same as the server with socks5.

tun2socks will work in ***tun2socks screen***

### add the script launch to crontab

```bash
sudo crontab -e
@reboot /bin/sh /home/tun2socks.sh
```
