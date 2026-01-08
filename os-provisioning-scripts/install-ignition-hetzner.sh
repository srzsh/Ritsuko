#!/usr/bin/bash
# Modified from https://github.com/kube-hetzner/kube-hetzner/blob/master/locals.tf

# Quit on Error / Show every line before execution
set -ex

# Download image and write it to disk
TMPFILE="$(mktemp -q 'openSUSE-MicroOS.x86_64.XXXXXXXXXX.qcow2')"
wget -O "$TMPFILE" 'https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-ContainerHost-kvm-and-xen.qcow2'
qemu-img convert -f qcow2 -O host_device "$TMPFILE" "$1"

# Move GPT trailer to end of disk
sfdisk --relocate gpt-bak-std "$1"

# Update partition table
partprobe "$1" && udevadm settle

SWAP_SIZE_GIB="${2:-4}"
#Create swap and ignition config partitions
PARTED_OUTPUT=$(parted -s "$1" unit MiB print)
DISK_END=$(printf "$PARTED_OUTPUT" | grep "Disk $1" | cut -d ' ' -f3 | tr -d 'MiB')
DISK_LAST_PARTITION_NUMBER=$(printf "$PARTED_OUTPUT" | tail -n1 | cut -d ' ' -f2)
SWAP_PARTITION_NUMBER=$((DISK_LAST_PARTITION_NUMBER+1))
SWAP_START=$((DISK_END-SWAP_SIZE_GIB*1024))
parted -s "$1" mkpart primary linux-swap "${SWAP_START}MiB" "${CONFIG_END}MiB"
parted -s "$1" mkpart primary ext4 "${CONFIG_END}MiB" 100%
partprobe "$1" && udevadm settle

mkswap "${1}${SWAP_PARTITION_NUMBER}"
mkfs.ext4 -L combustion "${1}$((SWAP_PARTITION_NUMBER+1))"
