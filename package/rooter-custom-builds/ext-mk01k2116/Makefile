#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-mk01k2116
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-mk01k2116
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+ext-mk01k21 \
  		+luci-app-mwan3 +luci-app-dnsmasq-ipset 
  TITLE:=ROOter support for MK01K21
  PKGARCH:=all
endef

define Package/ext-mk01k2116/description
  Helper scripts to enable ROOter support for MK01K21
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-mk01k2116))
