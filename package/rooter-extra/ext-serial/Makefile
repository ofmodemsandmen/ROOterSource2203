#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ext-serial
PKG_VERSION:=1.10.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zerotier/ZeroTierOne/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1cc6b5da059486aff588fa6e6f43d20a7063569cc108bbe7254969f1cf72c968
PKG_BUILD_DIR:=$(BUILD_DIR)/ZeroTierOne-$(PKG_VERSION)

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_LICENSE:=BSL 1.1
PKG_LICENSE_FILES:=LICENSE.txt

PKG_ASLR_PIE:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ext-serial
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  DEPENDS:=+libpthread +libstdcpp +kmod-tun +ip +libminiupnpc +libnatpmp
  TITLE:=Create Serial # generator
endef

define Package/ext-serial/description
	Serial # generator
endef

define Package/ext-serial/config
	source "$(SOURCE)/Config.in"
endef

MAKE_FLAGS += \
	ZT_EMBEDDED=1 \
	ZT_SSO_SUPPORTED=0 \
	DEFS="" \
	OSTYPE="Linux" \

define Build/Compile
	$(call Build/Compile/Default,one)
endef

# Make binary smaller
TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/ext-serial/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zerotier-one $(1)/usr/bin/serial-idtool
endef

$(eval $(call BuildPackage,ext-serial))
