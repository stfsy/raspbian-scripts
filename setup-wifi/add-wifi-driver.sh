#!/bin/bash

set -e

#https://github.com/Mange/rtl8192eu-linux-driver
declare -r WORKDIR=rtl8192eu-linux-driver

sudo apt-get install git raspberrypi-kernel-headers build-essential

git clone https://github.com/Mange/${WORKDIR}

cd ${WORKDIR}

# add rpi platform
sed -i '/CONFIG_PLATFORM_I386_PC = y/c\CONFIG_PLATFORM_I386_PC = n\nCONFIG_PLATFORM_ARM_RPI = y' ./Makefile

# enable tdls for i.e. chromecast

# now.. increase max mtu size
sed -i '/1500/c\1532' include/if_ether.h
sed -i '/1514/c\1546' include/if_ether.h
sed -i '/1514/c\1546' include/drv_types_ce.h
sed -i '/1514/c\1546' include/drv_types_xp.h
sed -i '/1514/c\1546' include/ethernet.h
sed -i '/1514/c\1546' include/wifi.h

# change wifi nickname
sed -i '/<WIFI@REALTEK>/c\rpi-wifi' ./os_dep/linux/ioctl_linux.c

sudo make
sudo make install

cd ..
#rm -rf ${WORKDIR}
