#!/bin/bash

# Perform setup
set -x
DEV_NAME="$(lsblk --output NAME --list | tail -n 1)" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
DEV_FS_TYPE="ext4"
MOUNT_POINT="/data"
set +x

# Format EBS volume, if not already formatted
sudo file -s "/dev/$DEV_NAME" | grep "$DEV_FS_TYPE"
if [ $? -eq 0 ]; then
  echo "File system already exists on /dev/$DEV_NAME, not going to format"
else
  echo "No file system on /dev/$DEV_NAME, formatting"
  sudo mkfs -t "$DEV_FS_TYPE" "/dev/$DEV_NAME"
fi

# Wait until we can determine the UUID of the EBS device that was attached
while true; do
  uuid="$(ls -la /dev/disk/by-uuid/ | grep $DEV_NAME | sed -e 's/.*\([0-9a-f-]\{36\}\).*/\1/')" # seems more reliable than using blkid :shrug:
  if [ ! -z "$uuid" ]; then
    echo "EBS device \"$uuid\" found"
    break
  fi
  echo "Waiting for EBS device..."
  sleep 1
done

# Mount EBS volume, and set it to auto-mount after reboots
sudo mkdir "$MOUNT_POINT"
echo "UUID=$uuid  $MOUNT_POINT  $DEV_FS_TYPE  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a

# List the filesystems, for debugging convenience
df -h
