#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=dir853
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/dir853
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Router Specific
  TITLE:=Install scripts for dir853
  PKGARCH:=all
endef

define Package/dir853/description
  Helper scripts to install scripts for dir853
endef


define Build/Compile
endef

define Package/dir853/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,dir853))
