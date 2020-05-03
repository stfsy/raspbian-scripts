#!/bin/bash

declare -r ETH_NAME=$(ifconfig | grep enx | cut -d: -f1)

./add-batman-and-alfred.sh
sudo batctl gw_mode server

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o ${ETH_NAME} -j MASQUERADE
sudo iptables -A FORWARD -i ${ETH_NAME} -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i bat0 -o ${ETH_NAME} -j ACCEPT

sudo ifconfig ${ETH_NAME} up
sudo ifconfig bat0 up