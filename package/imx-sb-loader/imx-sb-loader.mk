################################################################################
#
# imx-sb-loader
#
################################################################################

IMX_SB_LOADER_VERSION = 2.0.10
IMX_SB_LOADER_SITE = package/imx-sb-loader
# https://raw.githubusercontent.com/Rockbox/rockbox/refs/heads/master/utils/imxtools/sbtools/sbloader.c
IMX_SB_LOADER_SITE_METHOD = local
IMX_SB_LOADER_LICENSE = GPL
IMX_SB_LOADER_DEPENDENCIES = libusb host-pkgconf
HOST_IMX_SB_LOADER_DEPENDENCIES = host-libusb host-pkgconf

define HOST_IMX_SB_LOADER_BUILD_CMDS
	$(HOSTCC) $(HOST_CFLAGS) -I$(HOST_DIR)/include/libusb-1.0 \
		$(HOST_LDFLAGS) \
		$(@D)/sbloader.c -o $(@D)/sb_loader \
		-lusb-1.0
endef

define HOST_IMX_SB_LOADER_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sb_loader $(HOST_DIR)/bin/sb_loader
endef

$(eval $(host-generic-package))
