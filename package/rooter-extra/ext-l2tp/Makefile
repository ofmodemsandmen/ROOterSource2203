#Owned by DairyMan@Whirlpool 
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-l2tp
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-l2tp
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  DEPENDS:=+kmod-l2tp +kmod-l2tp-eth +kmod-l2tp-ip +kmod-pppol2tp \
			+ppp-mod-pppol2tp +xl2tpd +luci-proto-ipv6 +luci-proto-ppp
  TITLE:=Install L2TP VPN
  PKGARCH:=all
endef

define Package/ext-l2tp/description
  Helper scripts to install L2TP VPN
endef


define Build/Compile
endef

define Package/ext-l2tp/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-l2tp))
