#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=arc-storage
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/arc-storage
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Basic Applications
  DEPENDS:= +ntfs-3g +fdisk +kmod-usb-storage \
	    +kmod-fs-ext4 +kmod-fs-vfat +kmod-nls-cp437 +kmod-nls-iso8859-1 +kmod-nls-utf8 \
	    +block-mount +kmod-fs-exfat +kmod-fs-hfs
  TITLE:=Install USB Storage
  PKGARCH:=all
endef

define Package/arc-storage/description
  Helper scripts to install USB Storage
endef


define Build/Compile
endef

define Package/arc-storage/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,arc-storage))
