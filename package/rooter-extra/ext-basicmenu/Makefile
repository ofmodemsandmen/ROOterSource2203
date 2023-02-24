#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-basicmenu
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-basicmenu
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=support for Easy Basic menu
  PKGARCH:=all
endef

define Package/ext-basicmenu/description
  Helper scripts to add Easy Basic menu
endef


define Build/Compile
endef

define Package/ext-basicmenu/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-basicmenu))
