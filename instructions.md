# Building OpenWrt for Radxa Rock 5B+ on GitHub Codespaces

This guide will help you build a custom OpenWrt image for the Radxa Rock 5B+ using GitHub Codespaces, which provides a Linux environment with case-sensitive filesystem and eliminates local Docker issues.

## Prerequisites

- GitHub account (free tier includes 120 core-hours per month)
- Web browser

## Step 1: Create GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Create new repository**:
   - Click the "+" icon in top right corner
   - Select "New repository"
   - Repository name: `openwrt-radxa-rock5b-plus`
   - Set to Public (required for free Codespaces)
   - Check "Add a README file"
   - Click "Create repository"

## Step 2: Upload Configuration Files

1. **In your new repository**, click "Add file" → "Create new file"
2. **Create `.config` file**:
   - Filename: `.config`
   - Copy and paste the following content:

```
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_armv8=y
CONFIG_TARGET_rockchip_armv8_DEVICE_radxa_rock-5b-plus=y

# Compress target images
CONFIG_TARGET_IMAGES_GZIP=y

# --- Base network bits typically selected by default, but keep explicit lean image in mind ---

# ---- LuCI Web UI ----
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-app-firewall=y

# ---- LTE / EM7455 (QMI) ----
CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-wdm=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y
CONFIG_PACKAGE_kmod-usb-serial=y
CONFIG_PACKAGE_kmod-usb-serial-option=y
CONFIG_PACKAGE_uqmi=y
CONFIG_PACKAGE_luci-proto-qmi=y
CONFIG_PACKAGE_usb-modeswitch=y
# (Optional MBIM path)
# CONFIG_PACKAGE_umbim=y
# CONFIG_PACKAGE_luci-proto-mbim=y

# ---- Useful USB Ethernet dongles for first login ----
CONFIG_PACKAGE_kmod-usb-net-rtl8152=y   # RTL8152/RTL8153 (many USB-C dongles)
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y # CDC Ethernet (many dongles)
CONFIG_PACKAGE_kmod-usb-net-asix-ax88179=y # AX88179 (SuperSpeed USB 3.0)

# ---- File systems ----
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-ntfs=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-fs-exfat=y

# ---- USB Storage ----
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-uas=y
CONFIG_PACKAGE_block-mount=y

# ---- Extra Network Tools ----
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_ethtool=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget-ssl=y

# ---- WiFi drivers (if needed for USB WiFi adapters) ----
CONFIG_PACKAGE_kmod-cfg80211=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_wpa-supplicant=y

# ---- Additional useful packages ----
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_opkg=y
CONFIG_PACKAGE_ca-certificates=y
```

3. **Commit the file**:
   - Scroll down and click "Commit new file"

## Step 3: Create Build Script

1. **Create build script**: Click "Add file" → "Create new file"
2. **Filename**: `build.sh`
3. **Content**:

   ```bash
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
```

4. **Commit the file**

## Step 4: Launch GitHub Codespace

1. **In your repository**, click the green "Code" button
2. **Select "Codespaces" tab**
3. **Click "Create codespace on main"**
4. **Wait for setup** (usually 2-3 minutes)
   - Codespace will automatically provision a Linux environment
   - You'll get a VS Code interface in your browser

## Step 5: Build OpenWrt

1. **Open terminal** in Codespace:
   - Click Terminal menu → New Terminal
   - Or press `Ctrl+Shift+`` (backtick)

2. **Make build script executable**:
   ```bash
   chmod +x build.sh
   ```

3. **Start the build**:
   ```bash
   ./build.sh
   ```

4. **Monitor progress**:
   - The build will take 1-3 hours
   - You can see progress in the terminal
   - The script shows estimated completion time

## Step 6: Download Your Image

### Option A: Using Codespace File Browser
1. **Navigate** to `openwrt/bin/targets/rockchip/armv8/`
2. **Right-click** on `openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sdcard.img.gz`
3. **Select "Download"**

### Option B: Using Terminal
```bash
# Verify the image was created
ls -la openwrt/bin/targets/rockchip/armv8/

# Check file size (should be ~100-200MB compressed)
du -h openwrt/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sdcard.img.gz
```

## Step 7: Flash to SD Card

1. **Download and install** balenaEtcher: https://balena.io/etcher
2. **Insert SD card** (minimum 8GB recommended)
3. **Open balenaEtcher**:
   - Select your downloaded `.img.gz` file
   - Select your SD card
   - Click "Flash!"

## Troubleshooting

### Build Fails
- Check the terminal output for specific errors
- Most common issues are resolved by re-running: `make clean && ./build.sh`

### Out of Space
- Free up space: `make clean`
- Use larger Codespace machine type (go to Codespace settings)

### Missing Packages
- The script includes all necessary dependencies
- If something is missing, add it to the `apt-get install` line

## Customizing Your Build

### To modify packages:
1. **Edit `.config` file** in the Codespace
2. **Add/remove** `CONFIG_PACKAGE_` lines
3. **Re-run**: `make defconfig && make -j$(nproc) V=s`

### To use menuconfig (interactive):
```bash
cd openwrt
make menuconfig
# Navigate with arrow keys, Space to select, Save and Exit
make -j$(nproc) V=s
```

## Important Notes

- **Free GitHub accounts** get 120 core-hours per month
- **2-core Codespace** = ~60 hours of build time per month
- **4-core Codespace** = ~30 hours of build time per month
- **Build time**: 1-3 hours depending on machine specs
- **Image size**: ~100-200MB compressed, ~800MB uncompressed

## What's Included in This Build

✅ **Web Interface (LuCI)** with SSL support  
✅ **LTE/Cellular support** (QMI protocol for EM7455 modems)  
✅ **USB Ethernet dongles** (RTL8152, CDC Ethernet, AX88179)  
✅ **File system support** (ext4, NTFS, FAT, exFAT)  
✅ **USB storage** with UAS support  
✅ **Network tools** (tcpdump, iperf3, ethtool, htop, nano, curl, wget)  
✅ **WiFi support** for USB adapters  
✅ **SSH/SFTP** server support  

## Links and Resources

- **OpenWrt Documentation**: https://openwrt.org/docs/start
- **Radxa Rock 5B+ Wiki**: https://wiki.radxa.com/Rock5/5b
- **GitHub Codespaces Docs**: https://docs.github.com/en/codespaces
- **balenaEtcher**: https://balena.io/etcher

---

**Need help?** Create an issue in this repository with your build output and error messages.
