#!/bin/bash

writeIfNotSet() {
  confFile=$1
  conf=$2
  if grep -qe ^"$conf" "$confFile";
  then
    echo "$conf is already set in $confFile"
  else
    sudo echo "$conf" >> "$confFile"
  fi
}

writeKernelModuleIfNotSet() {
  writeIfNotSet "/etc/modules" "$1"
}

writeDhcpConfIfNotSet() {
  writeIfNotSet "/etc/dhcpcd.conf" "$1"
}

writeRcLocalConfIfNotSet() {
  writeIfNotSet "/etc/rc.local" "$1"
}

sudo apt-get -y install batctl alfred

writeKernelModuleIfNotSet 'batman-adv'
writeDhcpConfIfNotSet 'denyinterfaces wlan0'

sed -i "/exit 0/c\ " /etc/rc.local

writeRcLocalConfIfNotSet 'sudo batctl if add wlan0'
writeRcLocalConfIfNotSet 'sudo ifconfig wlan0 up'
writeRcLocalConfIfNotSet 'sudo ifconfig bat0 up'
writeRcLocalConfIfNotSet 'exit 0'

cp _bat0 /etc/network/interfaces.d/bat0
cp _wlan0 /etc/network/interfaces.d/wlan0

echo "Please remove wlan0 configuration from /etc/network/interfaces"
echo ".. and reboot"
