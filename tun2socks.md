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
FIRST_IP=$(hostname -I | cut -d ' ' -f1)
FIRST_INTERFACE=$(ip link show | grep -v 'lo' | head -n 1 | awk '{print $2}' | sed 's/://g')

ip tuntap add mode tun dev tun0
ip addr add 198.18.0.1/15 dev tun0
ip link set dev tun0 up
ip route del default
ip route add default via 198.18.0.1 dev tun0 metric 1
ip route add default via $FIRST_IP dev $FIRST_INTERFACE metric 10

screen -dmS tun2socks  /home/tun2socks-linux-amd64 -device tun0 -proxy socks5://192.168.100.102:2085 -interface $FIRST_INTERFACE
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