**************************
Freescale i.MX23 EVK board
**************************

This file documents the Buildroot support for the Freescale i.MX23 EVK board.

Build
=====

First, configure Buildroot for your i.MX23 EVK board:

  make imx23evk_defconfig

Build all components:

  make

You will find in output/images/ directory the following files:
  - imx23-evk.dtb
  - rootfs.tar
  - u-boot.sd
  - zImage
  - imx23-evk-enc28j60.dtb
  - linux-itb.sb
  - sb_loader

Create a bootable SD card
=========================

To determine the device associated to the SD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Then, run the following command:

*** WARNING! The command will destroy all the card content. Use with care! ***

 sudo dd if=output/images/sdcard.img of=/dev/<your-microsd-device>

Boot the i.MX23 EVK board
=========================

SD card:
- Put the Boot Mode Select jumper as 1 0 0 1 so that it can boot
  from the SD card
- Insert the SD card in the SD Card slot of the board;
- Connect an RS232 UART cable to the Debug UART Port and connect using a
  terminal emulator at 115200 bps, 8n1;
- Power on the board.

USB:
- Put the Boot Mode Select jumper as 0 0 0 0 so that it can boot
  from the USB
- Connect an RS232 UART cable to the Debug UART Port and connect using a
  terminal emulator at 115200 bps, 8n1
- Power on the board
- Execute on host PC:
  output/images/sb_loader -d -p hid output/images/linux-itb.sb.

NAND:
- Boot from SD card as described above. linux-itb.sb has to be in rootfs.
- Alternatively, boot from USB and use network to transfer
  linux-itb.sb to the board:
  ethtool -s eth0 speed 10 duplex full autoneg off
  dhcpc -i eth0
  inetd
- Write bootsream in NAND:
  kobs-ng -d -v -0 -w --search_exponent=1 linux-itb.sb
- Put the Boot Mode Select jumper as 0 1 0 0 so that it can boot from NAND
- Reboot.

Enjoy!
