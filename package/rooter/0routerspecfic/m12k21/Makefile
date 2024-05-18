#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=m12k21
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/m12k21
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Router Specific
  TITLE:=Install scripts for m12k21
  PKGARCH:=all
endef

define Package/m12k21/description
  Helper scripts to install scripts for m12k21
endef


define Build/Compile
endef

define Package/m12k21/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,m12k21))
