#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=multi-wifi
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/multi-wifi
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=support for simple wifi in Multi
  PKGARCH:=all
endef

define Package/multi-wifi/description
  Helper scripts to enable simple wifi in Multi
endef


define Build/Compile
endef

define Package/multi-wifi/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,multi-wifi))
