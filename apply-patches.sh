#!/bin/bash
#
# Copyright (C) 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Automatically apply required source tree patches for chenfeng
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_BUILD_TOP="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# 1. frameworks/native: GraphicBuffer 256-byte ABI fix
if [ -d "${ANDROID_BUILD_TOP}/frameworks/native" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/frameworks/native" log -n 50 --grep="Decouple DependencyMonitor to restore 256-byte ABI" --oneline 2>/dev/null | grep -q . && \
       ! grep -q "static DependencyMonitor sMonitor;" "${ANDROID_BUILD_TOP}/frameworks/native/libs/ui/GraphicBuffer.cpp" 2>/dev/null; then
        echo "[chenfeng] Applying frameworks/native GraphicBuffer ABI patch..."
        for patch in "${SCRIPT_DIR}/patches/frameworks_native/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/frameworks/native" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/frameworks/native" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 2. packages/modules/UprobeStats: min_sdk_version fix for NDK crtbegin_so version 36
if [ -d "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats" log -n 50 --grep="Lower min_sdk_version to 35" --oneline 2>/dev/null | grep -q . && \
       ! git -C "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats" diff 2>/dev/null | grep -q 'min_sdk_version: "35"' && \
       ! grep -q 'min_sdk_version: "35"' "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats/service/aidl/Android.bp" 2>/dev/null; then
        echo "[chenfeng] Applying packages/modules/UprobeStats min_sdk_version patch..."
        for patch in "${SCRIPT_DIR}/patches/packages_modules_UprobeStats/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/packages/modules/UprobeStats" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 3. hardware/xiaomi: /dev/xiaomi-touch ioctl support for DT2W, single tap, and SOFOD/UDFPS
if [ -d "${ANDROID_BUILD_TOP}/hardware/xiaomi" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/hardware/xiaomi" log -n 50 --grep="Support /dev/xiaomi-touch ioctl" --oneline 2>/dev/null | grep -q . && \
       ! grep -q "kTouchDevPath" "${ANDROID_BUILD_TOP}/hardware/xiaomi/sensors/v2/Sensor.cpp" 2>/dev/null; then
        echo "[chenfeng] Applying hardware/xiaomi touch ioctl patch..."
        for patch in "${SCRIPT_DIR}/patches/hardware_xiaomi/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/hardware/xiaomi" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/hardware/xiaomi" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 4. packages/providers/ContactsProvider: OPTION_CHECK_BRACKETS was removed
# in AOSP 16 / Rising frameworks/base; Lineage's provider still uses it
if [ -d "${ANDROID_BUILD_TOP}/packages/providers/ContactsProvider" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/packages/providers/ContactsProvider" log -n 50 --grep="drop OPTION_CHECK_BRACKETS" --oneline 2>/dev/null | grep -q . && \
       ! grep -q "OPTION_NONE, token -> {}" "${ANDROID_BUILD_TOP}/packages/providers/ContactsProvider/src/com/android/providers/contacts/util/SelectionBuilder.java" 2>/dev/null; then
        echo "[chenfeng] Applying ContactsProvider OPTION_CHECK_BRACKETS patch..."
        for patch in "${SCRIPT_DIR}/patches/packages_providers_ContactsProvider/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/packages/providers/ContactsProvider" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/packages/providers/ContactsProvider" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 5. frameworks/base: restore Lineage satellite-entitlement + OTP (Telephony)
# and trash (DocumentsContract) APIs dropped by Rising's fork
if [ -d "${ANDROID_BUILD_TOP}/frameworks/base" ]; then
    if ! grep -q "COLUMN_SATELLITE_ENTITLEMENT_BARRED_PLMNS" "${ANDROID_BUILD_TOP}/frameworks/base/core/java/android/provider/Telephony.java" 2>/dev/null; then
        echo "[chenfeng] Applying frameworks/base Lineage API restore patches..."
        for patch in "${SCRIPT_DIR}/patches/frameworks_base/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/frameworks/base" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/frameworks/base" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 6. packages/modules/Nfc: Rising dropped DISPLAY_CATEGORY_BUILT_IN_DISPLAYS
if [ -d "${ANDROID_BUILD_TOP}/packages/modules/Nfc" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/packages/modules/Nfc" log -n 50 --grep="avoid removed DISPLAY_CATEGORY_BUILT_IN_DISPLAYS" --oneline 2>/dev/null | grep -q . && \
       grep -q "DISPLAY_CATEGORY_BUILT_IN_DISPLAYS" "${ANDROID_BUILD_TOP}/packages/modules/Nfc/NfcNci/src/com/android/nfc/ScreenStateHelper.java" 2>/dev/null; then
        echo "[chenfeng] Applying Nfc built-in display category patch..."
        for patch in "${SCRIPT_DIR}/patches/packages_modules_Nfc/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/packages/modules/Nfc" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/packages/modules/Nfc" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 7. packages/apps/Dialer: Rising dropped Notification.Builder
# setRequestPromotedOngoing
if [ -d "${ANDROID_BUILD_TOP}/packages/apps/Dialer" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/packages/apps/Dialer" log -n 50 --grep="drop removed setRequestPromotedOngoing" --oneline 2>/dev/null | grep -q . && \
       grep -q "setRequestPromotedOngoing" "${ANDROID_BUILD_TOP}/packages/apps/Dialer/java/com/android/incallui/StatusBarNotifier.java" 2>/dev/null; then
        echo "[chenfeng] Applying Dialer setRequestPromotedOngoing patch..."
        for patch in "${SCRIPT_DIR}/patches/packages_apps_Dialer/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/packages/apps/Dialer" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/packages/apps/Dialer" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi

# 8. packages/providers/CallLogProvider: Rising dropped
# CallLog.Calls.PREFERRED_DISPLAY_NAME
if [ -d "${ANDROID_BUILD_TOP}/packages/providers/CallLogProvider" ]; then
    if ! git -C "${ANDROID_BUILD_TOP}/packages/providers/CallLogProvider" log -n 50 --grep="drop removed PREFERRED_DISPLAY_NAME" --oneline 2>/dev/null | grep -q . && \
       grep -q "PREFERRED_DISPLAY_NAME" "${ANDROID_BUILD_TOP}/packages/providers/CallLogProvider/src/com/android/calllogbackup/CallLogBackupAgent.java" 2>/dev/null; then
        echo "[chenfeng] Applying CallLogProvider PREFERRED_DISPLAY_NAME patch..."
        for patch in "${SCRIPT_DIR}/patches/packages_providers_CallLogProvider/"*.patch; do
            [ -f "$patch" ] && git -C "${ANDROID_BUILD_TOP}/packages/providers/CallLogProvider" apply --ignore-whitespace "$patch" 2>/dev/null || \
            patch -d "${ANDROID_BUILD_TOP}/packages/providers/CallLogProvider" -p1 -N -r - < "$patch" >/dev/null 2>&1 || true
        done
    fi
fi
