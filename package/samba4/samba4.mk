################################################################################
#
# samba4
#
################################################################################

SAMBA4_VERSION = 4.22.3
SAMBA4_SITE = https://download.samba.org/pub/samba/stable
SAMBA4_SOURCE = samba-$(SAMBA4_VERSION).tar.gz
SAMBA4_INSTALL_STAGING = YES
SAMBA4_LICENSE = GPL-3.0+
SAMBA4_LICENSE_FILES = COPYING
SAMBA4_CPE_ID_VENDOR = samba
SAMBA4_CPE_ID_PRODUCT = samba
SAMBA4_SELINUX_MODULES = samba
SAMBA4_DEPENDENCIES = \
	host-e2fsprogs host-flex host-heimdal host-nfs-utils \
	host-perl host-perl-parse-yapp host-python3 \
	cmocka e2fsprogs gnutls popt zlib \
	$(if $(BR2_PACKAGE_ICU),icu) \
	$(if $(BR2_PACKAGE_LIBAIO),libaio) \
	$(if $(BR2_PACKAGE_LIBCAP),libcap) \
	$(if $(BR2_PACKAGE_LIBGLIB2),libglib2) \
	$(if $(BR2_PACKAGE_READLINE),readline) \
	$(if $(BR2_PACKAGE_LIBXCRYPT),libxcrypt) \
	$(TARGET_NLS_DEPENDENCIES)
SAMBA4_CFLAGS = $(TARGET_CFLAGS)
SAMBA4_LDFLAGS = $(TARGET_LDFLAGS) $(TARGET_NLS_LIBS)
SAMBA4_CONF_ENV = \
	CFLAGS="$(SAMBA4_CFLAGS)" \
	LDFLAGS="$(SAMBA4_LDFLAGS)" \
	XSLTPROC=false \
	WAF_NO_PREFORK=1

SAMBA4_PYTHON = PYTHON="$(HOST_DIR)/bin/python3"
ifeq ($(BR2_PACKAGE_PYTHON3),y)
SAMBA4_PYTHON += PYTHON_CONFIG="$(STAGING_DIR)/usr/bin/python3-config"
SAMBA4_DEPENDENCIES += python3
else
SAMBA4_CONF_OPTS += --disable-python
endif

ifeq ($(BR2_PACKAGE_LIBICONV),y)
SAMBA4_DEPENDENCIES += libiconv
SAMBA4_LDFLAGS += -liconv
endif

ifeq ($(BR2_PACKAGE_LIBTIRPC),y)
SAMBA4_CFLAGS += `$(PKG_CONFIG_HOST_BINARY) --cflags libtirpc`
SAMBA4_LDFLAGS += `$(PKG_CONFIG_HOST_BINARY) --libs libtirpc`
SAMBA4_DEPENDENCIES += libtirpc host-pkgconf
endif

ifeq ($(BR2_PACKAGE_ACL),y)
SAMBA4_CONF_OPTS += --with-acl-support
SAMBA4_DEPENDENCIES += acl
else
SAMBA4_CONF_OPTS += --without-acl-support
endif

ifeq ($(BR2_PACKAGE_CUPS),y)
SAMBA4_CONF_ENV += CUPS_CONFIG="$(STAGING_DIR)/usr/bin/cups-config"
SAMBA4_CONF_OPTS += --enable-cups
SAMBA4_DEPENDENCIES += cups
else
SAMBA4_CONF_OPTS += --disable-cups
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
SAMBA4_DEPENDENCIES += dbus
SAMBA4_SHARED_MODULES += vfs_snapper
else
SAMBA4_SHARED_MODULES += !vfs_snapper
endif

ifeq ($(BR2_PACKAGE_DBUS)$(BR2_PACKAGE_AVAHI_DAEMON),yy)
SAMBA4_CONF_OPTS += --enable-avahi
SAMBA4_DEPENDENCIES += avahi
else
SAMBA4_CONF_OPTS += --disable-avahi
endif

ifeq ($(BR2_PACKAGE_LIBARCHIVE),y)
SAMBA4_CONF_OPTS += --with-libarchive
SAMBA4_DEPENDENCIES += libarchive
else
SAMBA4_CONF_OPTS += --without-libarchive
endif

ifeq ($(BR2_PACKAGE_LIBUNWIND),y)
SAMBA4_CONF_OPTS += --with-libunwind
SAMBA4_DEPENDENCIES += libunwind
else
SAMBA4_CONF_OPTS += --without-libunwind
endif

ifeq ($(BR2_PACKAGE_NCURSES),y)
SAMBA4_CONF_ENV += NCURSES_CONFIG="$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)"
SAMBA4_DEPENDENCIES += ncurses
else
SAMBA4_CONF_OPTS += --without-regedit
endif

# The ctdb tests (cluster) need bash and take up some space
# They're normally intended for debugging so remove them
define SAMBA4_REMOVE_CTDB_TESTS
	rm -rf $(TARGET_DIR)/usr/lib/ctdb-tests
	rm -rf $(TARGET_DIR)/usr/share/ctdb-tests
	rm -f $(TARGET_DIR)/usr/bin/ctdb_run_*tests
endef
SAMBA4_POST_INSTALL_TARGET_HOOKS += SAMBA4_REMOVE_CTDB_TESTS

define SAMBA4_CONFIGURE_CMDS
	$(INSTALL) -m 0644 package/samba4/samba4-cache.txt $(@D)/cache.txt;
	echo 'Checking whether fcntl supports setting/getting hints: $(if $(BR2_TOOLCHAIN_HEADERS_AT_LEAST_4_13),OK,NO)' >>$(@D)/cache.txt;
	echo 'Checking uname machine type: $(BR2_ARCH)' >>$(@D)/cache.txt;
	(cd $(@D); \
		$(SAMBA4_PYTHON) \
		python_LDFLAGS="" \
		python_LIBDIR="" \
		PERL="$(HOST_DIR)/bin/perl" \
		$(TARGET_CONFIGURE_OPTS) \
		$(SAMBA4_CONF_ENV) \
		./configure \
			--prefix=/usr \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--with-libiconv=$(STAGING_DIR)/usr \
			--enable-fhs \
			--cross-compile \
			--cross-answers=$(@D)/cache.txt \
			--hostcc=gcc \
			--disable-rpath \
			--disable-rpath-install \
			--disable-iprint \
			--without-fam \
			--without-pam \
			--without-dmapi \
			--without-gpgme \
			--without-ldb-lmdb \
			--disable-glusterfs \
			--with-cluster-support \
			--bundled-libraries='!asn1_compile,!compile_et' \
			--with-shared-modules=$(subst $(space),$(comma),$(strip $(SAMBA4_SHARED_MODULES))) \
			$(SAMBA4_CONF_OPTS) \
	)
endef

define SAMBA4_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(SAMBA4_PYTHON) $(MAKE) -C $(@D)
endef

define SAMBA4_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(SAMBA4_PYTHON) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define SAMBA4_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(SAMBA4_PYTHON) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

ifeq ($(BR2_PACKAGE_SAMBA4_AD_DC),y)
# host-python-dnspython and host-python-markdown are not strictly
# needed on the host, but on the target. however, samba's configure
# tests for their availability on the host.
SAMBA4_DEPENDENCIES += \
	jansson \
	host-python-dnspython \
	host-python-markdown \
	python-dnspython \
	python-markdown
else
SAMBA4_CONF_OPTS += --without-ad-dc --without-json
endif

ifeq ($(BR2_PACKAGE_SAMBA4_ADS),y)
SAMBA4_CONF_OPTS += --with-ads --with-ldap
SAMBA4_DEPENDENCIES += openldap
SAMBA4_SHARED_MODULES += idmap_ad
else
SAMBA4_CONF_OPTS += --without-ads --without-ldap
SAMBA4_SHARED_MODULES += !idmap_ad
endif

ifeq ($(BR2_PACKAGE_SAMBA4_SMBTORTURE),)
define SAMBA4_REMOVE_SMBTORTURE
	rm -f $(TARGET_DIR)/usr/bin/smbtorture
endef
SAMBA4_POST_INSTALL_TARGET_HOOKS += SAMBA4_REMOVE_SMBTORTURE
endif

define SAMBA4_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/samba4/S91smb \
		$(TARGET_DIR)/etc/init.d/S91smb
endef

ifeq ($(BR2_INIT_SYSTEMD),y)
SAMBA4_CONF_OPTS += --systemd-install-services
SAMBA4_DEPENDENCIES += systemd
endif

define SAMBA4_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(@D)/packaging/systemd/samba.conf.tmp \
		$(TARGET_DIR)/usr/lib/tmpfiles.d/samba.conf
	printf "d /var/log/samba  755 root root\n" >>$(TARGET_DIR)/usr/lib/tmpfiles.d/samba.conf
endef

$(eval $(generic-package))
