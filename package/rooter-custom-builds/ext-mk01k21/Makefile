#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-mk01k21
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-mk01k21
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic +pingtest +ext-logo \
  		+extramenu +ext-blacklist +ext-blockport +ext-domain \
		+luci-app-ddns +ddns-scripts +httping +curl \
		+luci-app-rootervpn +ext-wireguard \
		+ext-theme +luci-theme-argon +luci-theme-argondark +ext-login \
		+luci-theme-tomato +luci-theme-material \
		+webconsole +bwmon +464xlat \
		+ca-bundle +ca-certificates +libustream-wolfssl \
		+kmod-sched-cake +luci-app-nft-qos \
		+ext-command +ext-speedtest +luci-app-guestwifi \
		+openvpn-easy-rsa +openvpn-openssl \
		+ext-extra +luci-app-hotspot \
		+nano +picocom +wpad +wget +qfirehose 
  TITLE:=ROOter support for MK01K21
  PKGARCH:=all
endef

define Package/ext-mk01k21/description
  Helper scripts to enable ROOter support for MK01K21
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-mk01k21))
