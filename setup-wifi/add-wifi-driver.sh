#!/bin/bash

set -e

#https://github.com/Mange/rtl8192eu-linux-driver
declare -r WORKDIR=rtl8192eu-linux-driver

sudo apt-get install bc build-essential git raspberrypi-kernel-headers

git clone https://github.com/Mange/${WORKDIR}

cd ${WORKDIR}

# add rpi platform
sed -i '/CONFIG_PLATFORM_I386_PC = y/c\CONFIG_PLATFORM_I386_PC = n\nCONFIG_PLATFORM_ARM_RPI = y' ./Makefile

# change wifi nickname
sed -i '/<WIFI@REALTEK>/c\rpi-wifi' ./os_dep/linux/ioctl_linux.c

sudo make
sudo make install

cd ..
#rm -rf ${WORKDIR}
