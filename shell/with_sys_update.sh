#!/bin/bash
# in virtualbox, every time ubuntu system upgrades, it can't resize to
# fullscreen. execute this script to fix this.
# this script must be run as administrator using sudo.

apt-get install dkms build-essential linux-headers-$(uname -r)
/etc/init.d/vboxadd setup
