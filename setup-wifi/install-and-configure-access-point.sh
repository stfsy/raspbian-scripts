#!/bin/bash

set -e

declare -r CONF_FOLDER="conf"
declare -r TEMPLATE_CONF_FOLDER="_"${CONF_FOLDER}""

declare -r WIFI_PASSWORD=$1
declare -r WIFI_NAME=$2
declare -r ETH_NAME=$3

if [ -z "$WIFI_PASSWORD" ]
then
  echo "Please pass wifi password as arg 1"
  exit 1
fi

if [ -z "$WIFI_NAME" ]
then
  echo "Please pass wifi interface name as arg 2"
  echo "Hint: use $(ifconfig | grep wl | cut -d: -f1)"
  exit 1
fi

if [ -z "$ETH_NAME" ]
then
  echo "Please pass ethername interface name as arg 3"
  echo "Hint: use $(ifconfig | grep "^eth\|^enx" | cut -d: -f1)"
  exit 1
fi

writeKeyValuePairIfNotSet() {
  confFile=$1
  keyValueConf=$2
  if grep -qe ^"$keyValueConf" "$confFile";
  then
    echo "$1 is already set in /etc/sysctl.conf"
  else
    sudo echo "$keyValueConf" >> "$confFile"
  fi
}

writeSysCtlIfNotSet() {
  writeKeyValuePairIfNotSet "/etc/sysctl.conf" "$1"
}

writeDhcpConfIfNotSet() {
  writeKeyValuePairIfNotSet "/etc/dhcpcd.conf" "$1"
}

apt-get update && apt-get install dnsmasq hostapd iptables bridge-utils -y

sudo /etc/init.d/hostapd stop

cp "${TEMPLATE_CONF_FOLDER}"/_hostapd.conf ./"${CONF_FOLDER}"/hostapd.conf
cp "${TEMPLATE_CONF_FOLDER}"/_hostapd ./"${CONF_FOLDER}"/hostapd

cp "${TEMPLATE_CONF_FOLDER}"/_bridge-br0.netdev ./"${CONF_FOLDER}"/bridge-br0.netdev
cp "${TEMPLATE_CONF_FOLDER}"/_bridge-br0-slave.network ./"${CONF_FOLDER}"/bridge-br0-slave.network
cp "${TEMPLATE_CONF_FOLDER}"/_bridge-br0.network ./"${CONF_FOLDER}"/bridge-br0.network

sed -i "/WIFI_INTF/c\interface=${WIFI_NAME}" ./"${CONF_FOLDER}"/hostapd.conf
sed -i "/WIFI_PW/c\wpa_passphrase=${WIFI_PASSWORD}" ./"${CONF_FOLDER}"/hostapd.conf
sed -i "/WIFI_INTF/c\interface=${WIFI_NAME}" ./"${CONF_FOLDER}"/dnsmasq.conf
sed -i "/ETH_INTF/c\interface=${ETH_NAME}" ./"${CONF_FOLDER}"/bridge-br0-slave.network

cp ./"${CONF_FOLDER}"/hostapd.conf /etc/hostapd/hostapd.conf
cp ./"${CONF_FOLDER}"/hostapd /etc/default/hostapd
cp ./"${CONF_FOLDER}"/dnsmasq.conf /etc/dnsmasq.conf

cp ./"${CONF_FOLDER}"/bridge-br0.netdev /etc/systemd/network/bridge-br0.netdev
cp ./"${CONF_FOLDER}"/bridge-br0-slave.network /etc/systemd/network/bridge-br0-slave.network
cp ./"${CONF_FOLDER}"/bridge-br0.network /etc/systemd/network/bridge-br0.network

if grep -qe 1 "/proc/sys/net/ipv4/ip_forward"; 
then
  echo "Ip forwarding in /proc/sys/net/ipv4/ip_forward is already enabled"
else
  sudo sh -c "echo 1 >> /proc/sys/net/ipv4/ip_forward"
fi

writeSysCtlIfNotSet "net.ipv4.ip_forward=1"
writeSysCtlIfNotSet "net.ipv6.conf.all.disable_ipv6=1"
writeSysCtlIfNotSet "net.ipv6.conf.default.disable_ipv6=1"

writeDhcpConfIfNotSet "denyinterfaces ${WIFI_NAME}"
writeDhcpConfIfNotSet "denyinterfaces ${ETH_NAME}"

sudo brctl addbr br0
sudo brctl addif br0 ${ETH_NAME}

sudo systemctl restart systemd-networkd
sudo /etc/init.d/hostapd restart

sudo update-rc.d hostapd enable

sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-timesyncd

rm -rf "${CONF_FOLDER}"
