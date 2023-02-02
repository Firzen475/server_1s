#!/bin/bash
depmod
chmod 0666 /dev/usb-vhci
/etc/init.d/haspd start
lsusb | grep HASP
usbhaspd start








