#!/usr/bin/env bash

set -e
set -x

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

UBOOT_SPL=${BINARIES_DIR}/u-boot-spl.bin
UBOOT_BIN=${BINARIES_DIR}/u-boot.bin
export LINUX=${BINARIES_DIR}/zImage
export RAMDISK=${BINARIES_DIR}/rootfs.cpio.gz
DTB_EMMC=${BINARIES_DIR}/imx23-evk.dtb
DTB_ENC28J60=${BINARIES_DIR}/imx23-evk-enc28j60.dtb
RAMDISK_IMAGE_SIZE=$(printf "0x%x" `stat -c "%s" "$RAMDISK"`)
DTB_LIST="$DTB_ENC28J60 $DTB_EMMC"
ITB_IMAGE=${BINARIES_DIR}/linux.itb

main()
{
	# 1. Linux. initrd and DTB images
	cat ${BOARD_DIR}/bd/linux.bd.template | \
		sed -e "s!%UBOOT_SPL%!${UBOOT_SPL}!" | \
		sed -e "s!%UBOOT_BIN%!${UBOOT_BIN}!" | \
		sed -e "s!%LINUX%!${LINUX}!" | \
		sed -e "s!%RAMDISK%!${RAMDISK}!" | \
		sed -e "s!%DTB%!${DTB_ENC28J60}!" | \
		sed -e "s!%RAMDISK_SIZE%!${RAMDISK_IMAGE_SIZE}!" \
		>${BINARIES_DIR}/linux.bd

	echo "To program: sudo sb_loader -d -p hid ${BINARIES_DIR}/linux.sb"
	${HOST_DIR}/bin/elftosb --debug --zero-key -c ${BINARIES_DIR}/linux.bd -o ${BINARIES_DIR}/linux.sb


	# 2. FIT image
	LINUX_LOAD_ADDR=0x42000000 \
	RAMDISK_LOAD_ADDR=0x43000000 \
	FDT_LOAD_ADDR=0x41000000 \
		"${BOARD_DIR}/mkimage-fit-linux.sh" $DTB_LIST >"${BINARIES_DIR}/linux.its"

	"${HOST_DIR}/bin/mkimage" -f "${BINARIES_DIR}/linux.its" "$ITB_IMAGE"

	cat ${BOARD_DIR}/bd/linux-itb.bd.template | \
		sed -e "s!%UBOOT_SPL%!${UBOOT_SPL}!" | \
		sed -e "s!%UBOOT_BIN%!${UBOOT_BIN}!" | \
		sed -e "s!%ITB_IMAGE%!${ITB_IMAGE}!" \
		>${BINARIES_DIR}/linux-itb.bd

	echo "To program: sudo sb_loader -d -p hid ${BINARIES_DIR}/linux-itb.sb"
	${HOST_DIR}/bin/elftosb --debug --zero-key -c ${BINARIES_DIR}/linux-itb.bd -o ${BINARIES_DIR}/linux-itb.sb
}

main2()
{
	POWER_PREP=`find "${BUILD_DIR}/" -type f -name power_prep -print`
	BOOT_PREP=`find "${BUILD_DIR}/" -type f -name boot_prep -print`

	cat ${BOARD_DIR}/bd/mxs-bootlets.bd.template | \
		sed -e "s!%POWER_PREP%!${POWER_PREP}!" | \
		sed -e "s!%BOOT_PREP%!${BOOT_PREP}!" | \
		sed -e "s!%UBOOT_BIN%!${UBOOT_BIN}!" | \
		sed -e "s!%ITB_IMAGE%!${ITB_IMAGE}!" \
		>${BINARIES_DIR}/mxs-bootlets.bd

	echo "To program: sudo sb_loader -d -p hid ${BINARIES_DIR}/mxs-bootlets.sb"
	${HOST_DIR}/bin/elftosb --debug --zero-key -c ${BINARIES_DIR}/mxs-bootlets.bd -o ${BINARIES_DIR}/mxs-bootlets.sb
}

main "$@"
main2 "$@"