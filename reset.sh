#!/usr/bin/env bash

set -e -v

# Umount previous image
umount -f /mnt/sys
umount -f /mnt/dev/pts
umount -f /mnt/dev
umount -f /mnt/proc

# Remove old image and recreate
rm -f debian-rpi64.img
qemu-img create debian-rpi64.img 4G

# Mount the image to a loop device
LOOP_IMG=$(losetup -f -P --show debian-rpi64.img)

# Create a new partition table
parted ${LOOP_IMG} mktable msdos

# Partition the disk
parted ${LOOP_IMG} mkpart primary fat32 8192s 256MB
parted ${LOOP_IMG} mkpart primary 256MB 4096MB

# Format the new partitions
mkfs.vfat -F 32 -n BOOT ${LOOP_IMG}p1
mkfs.ext4 -L rootfs ${LOOP_IMG}p2

# Make a mount point for the rootFS
mkdir -p /mnt/
mount /dev/loop1p2 /mnt

# Mount the boot partition
mkdir -p /mnt/boot
mount /dev/loop1p1 /mnt/boot/
