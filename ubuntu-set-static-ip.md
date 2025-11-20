В Ununtu есть, особенность  (и встречается в других линукс подобных), что если вытащить видеокарту, меняется нумерация интерфейсов устройств. И ваши настройки интернета перестанут работать. Чтобы этого избежать, можно настроить по MAC адресу. Вводим:

ifconfig

находим сетевую карту и её MAC адрес

ether0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.105  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fe80::8e0:afff:fea5:3c4  prefixlen 64  scopeid 0x20<link>
        ether 0a:e0:af:a4:03:c4  txqueuelen 1000  (Ethernet)

настраиваем через netplan

sudo nano /etc/netplan/01-netcfg.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    ether0:
      dhcp4: no
      match:
        macaddress: 0a:e0:af:a4:03:c4
      set-name: ether0
      addresses:
        - 192.168.100.105/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
          addresses: [192.168.100.1]

После этого сохраните и закройте файл и примените изменения с помощью:
sudo netplan apply
Проверьте изменения, набрав:
ip addr show dev ether0