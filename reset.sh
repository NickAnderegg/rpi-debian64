#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND="noninteractive"

apt update -q
apt install -qy util-linux parted debootstrap xz-utils
apt install -qy qemu-utils qemu-user-static

# Umount previous image
umount -lq /mnt/sys || echo "Skipping unmounting /mnt/sys..."
umount -lq /mnt/dev/pts || echo "Skipping unmounting /mnt/dev/pts..."
umount -lq /mnt/dev || echo "Skipping unmounting /mnt/dev..."
umount -lq /mnt/proc || echo "Skipping unmounting /mnt/proc..."
umount -lq /mnt/boot || echo "Skipping unmounting /mnt/boot..."
umount -lq /mnt || echo "Skipping unmounting /mnt..."

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
mount ${LOOP_IMG}p2 /mnt

# Mount the boot partition
mkdir -p /mnt/boot
mount ${LOOP_IMG}p1 /mnt/boot/

apt-key --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
    adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys DCC9EFBF77E11517 DC30D7C23CBBABEE 4DFAB270CAA96DFA

apt-key --keyring /usr/share/keyrings/raspbian-archive-keyring.gpg \
    adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 9165938D90FDDD2E

apt-key --keyring /usr/share/keyrings/external-archives-keyring.gpg \
    adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys CAA5E9C8755D21A0 975DC25C4E730A3C

mkdir -p /mnt/usr/share/keyrings
cp /usr/share/keyrings/{debian,raspbian,external}-*-keyring.gpg /mnt/usr/share/keyrings/
