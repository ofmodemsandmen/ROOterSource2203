#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-scan
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-scan
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=support for Band Scan
  PKGARCH:=all
endef

define Package/ext-scan/description
  Helper scripts to add Band Scan
endef


define Build/Compile
endef

define Package/ext-scan/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-scan))
