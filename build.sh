
#!/bin/bash

# OpenWrt Build Script for Radxa Rock 5B+
set -e

echo "=== OpenWrt Build for Radxa Rock 5B+ ==="
echo "Start time: $(date)"

# Update system and install dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
     build-essential clang llvm lld gawk flex bison gperf \
     libncurses5-dev libncursesw5-dev zlib1g-dev libssl-dev \
    libelf-dev libgnutls28-dev gettext xsltproc rsync unzip zip \
    file wget curl git python3 python3-distutils python3-dev \
    python3-setuptools python3-pyelftools swig qemu-utils \
    upx-ucl time ca-certificates subversion

   # Clone OpenWrt source
echo "Cloning OpenWrt source..."
if [ -d "openwrt" ]; then
    echo "OpenWrt directory exists, removing..."
    rm -rf openwrt
fi

   git clone https://github.com/openwrt/openwrt.git
   cd openwrt

# Update and install feeds
echo "Updating feeds..."
   ./scripts/feeds update -a
   ./scripts/feeds install -a

# Copy configuration
echo "Applying configuration..."
   cp ../.config .

# Expand configuration
echo "Running make defconfig..."
   make defconfig

# Download sources
echo "Downloading source packages..."
   make -j$(nproc) download V=s

# Start build
echo "Starting build process..."
echo "This will take 1-3 hours depending on Codespace specs..."
   make -j$(nproc) V=s

echo "=== Build Complete ==="
echo "End time: $(date)"
echo ""
echo "Your image should be located at:"
echo "openwrt/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sdcard.img.gz"
echo ""
echo "Download it using the Codespace file browser or with:"
echo "ls -la openwrt/bin/targets/rockchip/armv8/"
