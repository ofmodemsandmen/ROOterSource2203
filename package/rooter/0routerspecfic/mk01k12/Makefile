#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=mk01k12
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/mk01k12
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Router Specific
  TITLE:=Install scripts for mk01k12
  PKGARCH:=all
endef

define Package/mk01k12/description
  Helper scripts to install scripts for mk01k12
endef


define Build/Compile
endef

define Package/mk01k12/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,mk01k12))
