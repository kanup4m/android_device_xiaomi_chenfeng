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
