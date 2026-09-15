#
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from chenfeng device
$(call inherit-product, device/xiaomi/chenfeng/device.mk)

# Inherit some common PixelOS stuff.
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

# Boot animation
TARGET_SCREEN_WIDTH := 1080
TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_NAME := custom_chenfeng
PRODUCT_DEVICE := chenfeng
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := 24053PY09I

PRODUCT_SYSTEM_NAME := chenfeng_global
PRODUCT_SYSTEM_DEVICE := chenfeng

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="chenfeng_global-user 16 BP2A.250605.031.A3 OS3.0.307.0.WNJCNXM release-keys" \
    BuildFingerprint=Xiaomi/chenfeng_global/chenfeng:16/BP2A.250605.031.A3/OS3.0.307.0.WNJCNXM:user/release-keys \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
