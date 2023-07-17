#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=h721ax
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/h721ax
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Router Specific
  DEPENDS:=+kmod-ath10k +kmod-ath9k \
	 +kmod-mt7915e
  TITLE:=Install scripts for Dual-Q H721
  PKGARCH:=all
endef

define Package/h721ax/description
  Helper scripts to install scripts for Dual-Q H721
endef


define Build/Compile
endef

define Package/h721ax/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,h721ax))
