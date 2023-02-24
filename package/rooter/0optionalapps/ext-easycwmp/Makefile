# Copyright (C) 2012-2016 PIVA Software <www.pivasoftware.com>
# 	Author: MOHAMED Kallel <mohamed.kallel@pivasoftware.com>
# 	Author: ANIS ELLOUZE <anis.ellouze@pivasoftware.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=ext-easycwmp
PKG_VERSION:=1.8.6

PKG_FIXUP:=autoreconf

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ext-easycwmp
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=CWMP client (using libcurl)
  DEPENDS:=+libubus +libuci +libubox +libmicroxml +libjson-c +libcurl +curl +ext-serial
endef

define Package/ext-easycwmp/description
 An open source implementation of the client CWMP (TR-069) protocol
endef

define Build/Prepare
	$(CP) ./easycwmp/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include

CONFIGURE_ARGS += \
	--enable-jsonc=1

define Package/ext-easycwmp/conffiles
/etc/config/easycwmp
/usr/share/easycwmp/defaults
endef

define Package/ext-easycwmp/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/easycwmpd $(1)/usr/sbin
endef

$(eval $(call BuildPackage,ext-easycwmp))
