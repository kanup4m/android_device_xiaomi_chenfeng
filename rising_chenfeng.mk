#
# Copyright (C) 2024 The LineageOS Project
# Copyright (C) 2026 RisingOS-Revived
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Rising stuff (Revived base is LineageOS).
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from chenfeng device
$(call inherit-product, device/xiaomi/chenfeng/device.mk)

PRODUCT_NAME := rising_chenfeng
PRODUCT_DEVICE := chenfeng
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi 14 Civi

PRODUCT_SYSTEM_NAME := chenfeng_global
PRODUCT_SYSTEM_DEVICE := chenfeng

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="chenfeng_global-user 16 BP2A.250605.031.A3 OS3.0.307.0.WNJCNXM release-keys" \
    BuildFingerprint="Xiaomi/chenfeng_global/chenfeng:16/BP2A.250605.031.A3/OS3.0.307.0.WNJCNXM:user/release-keys" \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME) \
    RisingChipset="Snapdragon 8s Gen 3" \
    RisingMaintainer="Beyonder"

RISING_MAINTAINER := Beyonder

# RisingOS device flags
TARGET_ENABLE_BLUR := true
TARGET_HAS_UDFPS := true
PRODUCT_NO_CAMERA := true # Aperture off, Leica MiuiCamera is bundled via chenfeng-miuicamera

# RisingOS build flags (CORE GMS)
WITH_GMS := true
TARGET_USES_PICO_GAPPS := true

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
