# Install Pi-compatible WiFi drivers to image

set -e

mkdir wifi-firmware
cd wifi-firmware
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin
#wget https://github.com/RPi-Distro/firmware-nonfree/raw/4ee44af381d55bc2221cf80c1433842a48ed09e1/brcm/brcmfmac43430-sdio.clm_blob
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.bin
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.clm_blob
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.txt
cp *sdio* /mnt/lib/firmware/brcm/
cd ..
rm -rf wifi-firmware

# Remove stage2.sh from root and unmount filesystem and mount points

rm /mnt/stage2.sh
umount /mnt/proc
umount /mnt/sys
umount /mnt/dev/pts
umount /mnt/dev -l
umount /mnt/boot
umount /mnt -l
