#!/bin/bash

# This script loads I2C drivers so OpenRGB is able to control
# DRAM modules and Motherboard RGB (chipset specific driver)
# and other PCIe based devices (i2c-dev)

# Always load this one
modprobe i2c-dev

# Load these depending on AMD or Intel systems
if lscpu | grep -qi 'vendor id:.*amd'; then
  #echo "i2c-piix4" >> /etc/modprobe-load.d/i2c.conf
  modprobe i2c-piix4
elif lscpu | grep -qi 'vendor id:.*intel'; then
  #echo "i2c-i801" >> /etc/modprobe-load.d/i2c.conf
  modprobe i2c-i801
else
  echo "Loading i2c driver for OpenRGB SMBus access: Unknown CPU vendor"
fi