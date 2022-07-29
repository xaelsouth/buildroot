#!/usr/bin/env bash

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#

main()
{
	local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	local LINUX_DIR="${BUILD_DIR}/linux-5.4-2.1.x-imx_var01"

	for dt in $DTB_LIST; do
		cp -f "${LINUX_DIR}/arch/arm/boot/dts/`basename $dt`.dtb" "${BINARIES_DIR}/"
	done

	exit $?
}

main $@
