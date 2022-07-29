****************************
Variscite DART-6UL EVK board
****************************

This file documents the Buildroot support for the Variscite DART-6UL board
based on NXP/Freescale i.MX6 UltraLite.

Please read the DART-6UL EVK Quick Start Guide [1] and DART-6UL v1.X, DART-6UL-5G v2.X
Datasheet [4] for an introduction to the board.

Build
=====

First, configure Buildroot for your DART-6UL EVK board:

In order to to do so there are two supported options:

  $ make variscite_dart6ulevk_mmc_defconfig

if you plan to use a board with eMMC.

Or

  $ make variscite_dart6ulevk_nand_defconfig

if you plan to use a board with NAND. However, this option is in planning and
not supported now.

Then you can edit the build options using

  $ make menuconfig

Build all components:

  $ make

You will find in ./output/images/ the following files:
  - imx6ul-var-dart-6ulcustomboard-emmc-wifi.dtb
  - imx6ul-var-dart-6ulcustomboard-emmc-sd-card.dtb
  - imx6ul-var-dart-6ulcustomboard-nand-wifi.dtb
  - imx6ul-var-dart-6ulcustomboard-nand-sd-card.dtb
  - rootfs.ext4
  - rootfs.tar
  - sdcard.img
  - boot.vfat
  - SPL
  - u-boot.bin
  - u-boot.img
  - zImage

Create a bootable microSD card
==============================

To determine the device associated to the microSD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Buildroot prepares a bootable "sdcard.img" image in the output/images/
directory, ready to be dumped on a microSD card. Launch the following
command as root:

  dd if=./output/images/sdcard.img of=/dev/<your-microsd-device>

*** WARNING! This will destroy all the card content. Use with care! ***

For details about the medium image layout, see the definition in
board/freescale/common/imx/genimage.cfg.template.

Boot the DART-6UL EVK board
=========================

To boot your newly created system (refer to the [1] for guidance):
- insert the microSD card in the microSD slot of the board;
- verify that your DART-6UL EVK board jumpers and switches are set as mentioned
  in the Quick Start Guide [1];
- put a micro USB cable into the Debug USB Port and connect using a terminal
  emulator at 115200 bps, 8n1;
- power on the board.

Enjoy!

References
==========
[1] https://www.variscite.com/wp-content/uploads/2017/12/DART-6UL-quick-start-guide.pdf
[2] https://www.variscite.com/wp-content/uploads/2017/12/VAR-6ULCustomBoard-Datasheet.pdf
[3] https://www.variscite.com/wp-content/uploads/2017/12/DART-6UL_Product_Brief.pdf
[4] https://www.variscite.com/wp-content/uploads/2018/01/DART-6UL_DART-6UL-5G-Datasheet.pdf
[5] https://variwiki.com/index.php?title=DART-6UL
