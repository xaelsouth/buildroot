################################################################################
#
# privoxy
#
################################################################################

PRIVOXY_VERSION = 4.0.0
PRIVOXY_SITE = https://downloads.sourceforge.net/project/ijbswa/Sources/$(PRIVOXY_VERSION)%20%28stable%29
PRIVOXY_SOURCE = privoxy-$(PRIVOXY_VERSION)-stable-src.tar.gz
# configure not shipped
PRIVOXY_AUTORECONF = YES
PRIVOXY_DEPENDENCIES = $(if $(BR2_PACKAGE_PCRE2),pcre2,pcre) zlib
PRIVOXY_LICENSE = GPL-2.0+
PRIVOXY_LICENSE_FILES = LICENSE
PRIVOXY_CPE_ID_VENDOR = privoxy
PRIVOXY_SELINUX_MODULES = privoxy

$(eval $(autotools-package))
