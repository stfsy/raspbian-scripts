#!/bin/bash

sudo apt-get install apt-transport-https ca-certificates software-properties-common -y

# install docker
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

# allow pi to docker docker without sudo
sudo usermod -aG docker pi

# import docker gpg key
sudo curl https://download.docker.com/linux/raspbian/gpg

echo "deb https://download.docker.com/linux/raspbian/ stretch stable" | sudo tee -a /etc/apt/sources.list

# start docker service
sudo systemctl start docker.service

rm ./deb

docker info

