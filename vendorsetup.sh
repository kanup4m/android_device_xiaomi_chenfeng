# Welcome to xiaomi-chenfeng aosp trees
# This script for auto cloning some stuff before building

# Clone kernel tree
if [ ! -d "device/xiaomi/chenfeng-kernel" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/android_device_xiaomi_chenfeng-kernel.git -b lineage-23.2 device/xiaomi/chenfeng-kernel
fi

# Clone hardware xiaomi
if [ ! -d "hardware/xiaomi" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/android_hardware_xiaomi-chenfeng.git -b lineage-23.2 hardware/xiaomi
fi

# Clone miuicamera
if [ ! -d "device/xiaomi/chenfeng-miuicamera" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/android_device_xiaomi_chenfeng-miuicamera.git -b lineage-23.2 device/xiaomi/chenfeng-miuicamera
fi


## BELOW ARE PROPRIETARY BLOBS

# Clone vendor device chenfeng
if [ ! -d "vendor/xiaomi/chenfeng" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/vendor_xiaomi_chenfeng.git -b lineage-23.2 vendor/xiaomi/chenfeng
fi

# Clone vendor miuicamera
if [ ! -d "vendor/xiaomi/chenfeng-miuicamera" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/vendor_xiaomi_chenfeng-miuicamera.git -b lineage-23.2 vendor/xiaomi/chenfeng-miuicamera
fi

# Clone custom dolby
if [ ! -d "hardware/dolby" ]; then
    git clone https://gitlab.com/xiaomi-chenfeng/hardware_dolby.git -b 16 hardware/dolby
fi


# Apply required source tree patches for chenfeng
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/apply-patches.sh"

# Finish clone all stuff
# Happy Build and Brick
