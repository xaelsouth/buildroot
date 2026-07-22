#!/bin/sh
# SPDX-License-Identifier: GPL-2.0+
#
# script to generate FIT image source for i.MX233 EVK boards
#
# usage: $0 <dt_name> [<dt_name> [<dt_name] ...]

[ -z "$LINUX" ] && LINUX="zImage"
[ -z "$RAMDISK" ] && RAMDISK="rootfs.cpio.gz"

if [ ! -f $LINUX ]; then
	echo "ERROR: LINUX file $LINUX not found" >&2
	exit 1
else
	echo "LINUX $LINUX goes at $LINUX_LOAD_ADDR" >&2
	echo "$LINUX size: `stat -c %s "$LINUX"`" >&2
fi

if [ ! -f $RAMDISK ]; then
	echo "WARNING: RAMDISK file $RAMDISK not found" >&2
else
	echo "RAMDISK $RAMDISK goes at $RAMDISK_LOAD_ADDR" >&2
	echo "$RAMDISK size: `stat -c %s "$RAMDISK"`" >&2
fi

for dtname in $*
do
	echo "$dtname size: `stat -c %s "$dtname"`" >&2
done

echo "Flat device tree goes at $FDT_LOAD_ADDR" >&2

cat << __HEADER_EOF
/dts-v1/;

/ {
    description = "Kernel, Device Tree & RootFS";

	images {
		kernel {
				description = "Kernel";
				data = /incbin/("$LINUX");
				type = "kernel";
				arch = "arm";
				os = "linux";
				compression = "none";
				load = <$LINUX_LOAD_ADDR>;
				entry = <$LINUX_LOAD_ADDR>;
				hash-1 {
					algo = "sha256";
				};
		};

__HEADER_EOF

if [ -f "$RAMDISK" ]; then
cat << __CONF_RAMDISK_EOF
		ramdisk {
				description = "Ramdisk";
				data = /incbin/("$RAMDISK");
				type = "ramdisk";
				arch = "arm";
				os = "linux";
				load = <$RAMDISK_LOAD_ADDR>;
				compression = "none";
				hash-1 {
					algo = "sha256";
				};
		};

__CONF_RAMDISK_EOF
fi

cnt=1
for dtname in $*
do
cat << __FDT_IMAGE_EOF
		fdt-$(basename ${dtname%.dtb}) {
				description = "Device Tree: $(basename $dtname .dtb)";
				data = /incbin/("$dtname");
				type = "flat_dt";
				compression = "none";
				load = <$FDT_LOAD_ADDR>;
				hash-1 {
					algo = "sha256";
				};
		};

__FDT_IMAGE_EOF
cnt=$((cnt+1))
done

cat << __CONF_HEADER_EOF
	};

	configurations {
		default = "config-$(basename ${1%.dtb})";

__CONF_HEADER_EOF

cnt=1
for dtname in $*
do
cat << __CONF_SECTION1_EOF
		config-$(basename ${dtname%.dtb}) {
				description = "Configuration: $(basename ${dtname%.dtb})";
				kernel = "kernel";
				ramdisk = "ramdisk";
				fdt = "fdt-$(basename ${dtname%.dtb})";
				hash-1 {
					algo = "sha256";
				};
		};

__CONF_SECTION1_EOF
cnt=$((cnt+1))
done

cat << __ITS_EOF
	};
};
__ITS_EOF
