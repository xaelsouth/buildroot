#!/usr/bin/env bash

set -e

BOARD_DIR="$(dirname $0)"

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list()
{
	#local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	#for dt in $DTB_LIST; do
	#	echo -n "\"`basename $dt`.dtb\", "
	#done

	echo -n "\"imx6ulz-var-dart-6ulcustomboard-emmc-wifi.dtb\", "
}

#
# linux_image extracts the Linux image format from BR2_LINUX_KERNEL_UIMAGE in
# ${BR_CONFIG}, then prints the corresponding file name for the genimage
# configuration file
#
linux_image()
{
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		echo "\"uImage\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGE=y$" ${BR2_CONFIG}; then
		echo "\"Image\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGEGZ=y$" ${BR2_CONFIG}; then
		echo "\"Image.gz\""
	else
		echo "\"zImage\""
	fi
}

genimage_type()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MN=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MP=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8X=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_LINUX_KERNEL_INSTALL_TARGET=y$" ${BR2_CONFIG}; then
		if grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" ${BR2_CONFIG}; then
		    echo "genimage.cfg.template_no_boot_part_spl"
		else
		    echo "genimage.cfg.template_no_boot_part"
		fi
	elif grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_spl"
	else
		echo "genimage.cfg.template"
	fi
}

imx_offset()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" ${BR2_CONFIG}; then
		echo "33K"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" ${BR2_CONFIG}; then
		echo "33K"
	else
		echo "32K"
	fi
}

uboot_image()
{
	if grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMX=y$" ${BR2_CONFIG}; then
		echo "u-boot-dtb.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMX=y$" ${BR2_CONFIG}; then
		echo "u-boot.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMG=y$" ${BR2_CONFIG}; then
	    echo "u-boot-dtb.img"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMG=y$" ${BR2_CONFIG}; then
	    echo "u-boot.img"
	fi
}

make_file()
{
	# ensure file is absent
	[[ ! -e "$1" ]] || rm "$1"

	# create a sparse file to speed things up
	truncate -s "$2" "$1"
}

make_ext4()
{
	local path="$1"
	local size="$2"

	make_file "$1" "$2"
	mkfs.ext4 \
		-U clear -E hash_seed=8e816b64-112a-11ed-a576-0b42625b70f7 \
		-I 256 \
		"$1"
}

make_vfat()
{
	local path="$1"
	local size="$2"

	make_file "$1" "$2"
	mkfs.vfat \
		-r 512 \
		"$1"
}

main()
{
	local FILES="$(dtb_list) $(linux_image)"
	local IMXOFFSET="$(imx_offset)"
	local UBOOTBIN="$(uboot_image)"
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

	sed -e "s/%FILES%/${FILES}/" \
		-e "s/%IMXOFFSET%/${IMXOFFSET}/" \
		-e "s/%UBOOTBIN%/${UBOOTBIN}/" \
		"${BOARD_DIR}/$(genimage_type)" > ${GENIMAGE_CFG}

	rm -rf "${GENIMAGE_TMP}"

	make_ext4 ${BINARIES_DIR}/factory.ext4 4M
	make_file ${BINARIES_DIR}/uboot.env 8K

	genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	rm -f ${GENIMAGE_CFG}

	exit $?
}

main $@
