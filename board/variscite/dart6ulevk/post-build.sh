#!/usr/bin/env bash

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#

set -e

BOARD_DIR="$(dirname $0)"

main()
{
	local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	local LINUX_KERNEL_VERSION="$(sed -n 's/^BR2_LINUX_KERNEL_VERSION="\([\/a-z0-9 _\.\-]*\)"$/\1/p' ${BR2_CONFIG})"

	local LINUX_DIR="${BUILD_DIR}/linux-${LINUX_KERNEL_VERSION}"

	for dt in $DTB_LIST; do
		cp -f "${LINUX_DIR}/arch/arm/boot/dts/`basename $dt`.dtb" "${BINARIES_DIR}/"
	done

	chmod 600 $TARGET_DIR/etc/NetworkManager/system-connections/*.nmconnection

	touch -a -m -t 200001010000 $TARGET_DIR/usr/lib/clock-epoch
	#touch -a -m -t `date -u +"%Y%m%d%H%M"` $TARGET_DIR/usr/lib/clock-epoch

	exit $?
}

main $@
