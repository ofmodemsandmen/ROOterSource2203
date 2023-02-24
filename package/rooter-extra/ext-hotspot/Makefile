#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-hotspot
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-hotspot
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=support for Hotspot
  PKGARCH:=all
endef

define Package/ext-hotspot/description
  Helper scripts to add Hotspot
endef


define Build/Compile
endef

define Package/ext-hotspot/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-hotspot))
