#!/bin/bash

set -e

if [ $# -ne 2 ]; then
  >&2 echo "usage: provision-swap.sh SWAP_FILE_SIZE SWAPPINESS"
  exit 1
fi

SWAP_FILE_SIZE=$1
SWAPPINESS=$2

echo "Setting up a swap file (size: $SWAP_FILE_SIZE, swappiness: $SWAPPINESS)..."

# Create the swap file
sudo fallocate -l ${SWAP_FILE_SIZE} /swapfile

# Only root should be able to access to this file
sudo chmod 600 /swapfile

# Define the file as swap space
sudo mkswap /swapfile

# Enable the swap file, allowing the system to start using it
sudo swapon /swapfile

# Make the swap file permanent, otherwise, previous settings will be lost on reboot
# Create a backup of the existing fstab, JustInCase(tm)
sudo cp /etc/fstab /etc/fstab.bak
# Add the swap file information at the end of the fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Adjust the swappiness
# With the default value of 10, the host will use swap if it has almost no other choice. Value is between 0 and 100.
# 100 will make the host use the swap as much as possible, 0 will make it use only in case of emergency.
# As swap access is slower than RAM access, having a low value here for a server is better.
sudo sysctl vm.swappiness=${SWAPPINESS}

# Make this setting permanent, to not lose it on reboot
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "vm.swappiness=${SWAPPINESS}" | sudo tee -a /etc/sysctl.conf
