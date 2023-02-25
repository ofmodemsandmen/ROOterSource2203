#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-vpnbypass
PKG_VERSION:=4.500
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

# +kmod-rt2800-usb

define Package/luci-app-vpnbypass
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  DEPENDS:=+luci-mod-admin-full +vpnbypass
  TITLE:=Provides Web UI for VPNBypass service.
  PKGARCH:=all
endef

define Package/luci-app-vpnbypass/description
  Provides Web UI for VPNBypass service.
endef


define Build/Compile
endef

define Package/luci-app-vpnbypass/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,luci-app-vpnbypass))
