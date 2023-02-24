#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-axt1800
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-axt1800
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic \
		+webconsole \
		+ext-theme +luci-theme-argon +luci-theme-argondark +ext-login \
		+luci-theme-tomato \
		+ext-extra +luci-app-hotspot +luci-app-guestwifi \
		+usbmuxd +libusbmuxd-utils +libimobiledevice-utils +kmod-usb-net-ipheth \
		+ext-splashconfig \
		+nano +picocom +wpad  
  TITLE:=ROOter support w/o MWan3 for 16meg and larger routers
  PKGARCH:=all
endef

define Package/ext-axt1800/description
  Helper scripts to enable ROOter w/o MWan3 on 16meg and larger routers
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-axt1800))
