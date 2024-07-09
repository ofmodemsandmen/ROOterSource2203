#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-smart
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-smart
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic +build-admin \
		+luci-app-ddns +ddns-scripts +pingtest \
		+extramenu +ext-blockport +ext-domain +ext-blacklist \
		+luci-app-rootervpn +ext-wireguard \
		+bwmon +464xlat +webconsole \
		+ext-theme +luci-theme-argon \
		+ca-bundle +ca-certificates \
		+arc-storage \
		+luci-app-sqm +kmod-sched-cake +luci-app-nft-qos \
		+ext-command +ext-speedtest \
		+openvpn-easy-rsa +openvpn-openssl \
		+ext-extra +luci-app-hotspot +luci-app-guestwifi \
		+usbmuxd +libusbmuxd-utils +libimobiledevice-utils +kmod-usb-net-ipheth \
		++luci-ssl +usbutils +openssl-util +irqbalance \
		+wget +luci-app-vpnbypass +coreutils-base64 \
		+ext-zerotier +ext-texting
  TITLE:=ROOter support for Smart routers
  PKGARCH:=all
endef

define Package/ext-smart/description
  Helper scripts to enable support for Smart routers
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-smart))
