include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ipq60xx
BOARDNAME:=Qualcomm Atheros IPQ60xx
FEATURES:=squashfs ramdisk fpu nand rtc emmc
KERNELNAME:=Image dtbs
CPU_TYPE:=cortex-a53
SUBTARGETS:=generic

KERNEL_PATCHVER:=5.10

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	kmod-leds-gpio kmod-gpio-button-hotplug \
	kmod-qca-nss-dp \
	kmod-ath11k-ahb \
	ath11k-firmware-ipq6018 \
	uboot-envtools \
	nss-firmware-ipq6018 kmod-qca-nss-drv

$(eval $(call BuildTarget))
