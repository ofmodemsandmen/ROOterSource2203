#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-vpn-policy-routing
PKG_VERSION:=4.500
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

# +kmod-rt2800-usb

define Package/luci-app-vpn-policy-routing
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  DEPENDS:=+luci-compat +luci-mod-admin-full +vpn-policy-routing
  TITLE:=VPN Policy-Based Routing Service Web UI
  PKGARCH:=all
endef

define Package/luci-app-vpn-policy-routing/description
  VPN Policy-Based Routing Service Web UI
endef


define Build/Compile
endef

define Package/luci-app-vpn-policy-routing/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,luci-app-vpn-policy-routing))
