#!/usr/bin/env bash
set -euo pipefail
WORKDIR="$(pwd)"
BUILD_DIR="$WORKDIR/openwrt/build_dir/target-aarch64_generic_musl/linux-rockchip_armv8"
GEN="$WORKDIR/openwrt/scripts/gen_image_generic.sh"
BOOT_DIR="$BUILD_DIR/tmp/openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sysupgrade.img.gz.boot"
ROOTFS="$BUILD_DIR/root.ext4"
OUT_TMP="$BUILD_DIR/tmp/openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sdcard.img.gz"
OUT_FINAL="$WORKDIR/openwrt/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-radxa_rock-5b-plus-ext4-sdcard.img.gz"
KERNELSIZE=16
ROOTFSSIZE=104
ALIGN=32768
mkdir -p "$(dirname "$OUT_FINAL")"
if [ ! -x "$GEN" ]; then echo "gen script missing or not executable: $GEN" >&2; exit 2; fi
if [ ! -d "$BOOT_DIR" ]; then echo "boot dir missing: $BOOT_DIR" >&2; exit 3; fi
if [ ! -f "$ROOTFS" ]; then echo "rootfs missing: $ROOTFS" >&2; exit 4; fi
rm -f "$OUT_TMP" "$OUT_TMP.new"
# Force GUID so gen_image_generic.sh uses mkfs.fat + mcopy (no root mounts)
export GUID=1
# Run the gen script to assemble sdcard image
"$GEN" "$OUT_TMP" "$KERNELSIZE" "$BOOT_DIR" "$ROOTFSSIZE" "$ROOTFS" "$ALIGN"
# Some scripts write .new first
if [ -f "$OUT_TMP.new" ]; then mv -f "$OUT_TMP.new" "$OUT_TMP"; fi
if [ ! -f "$OUT_TMP" ]; then echo "gen script failed to create $OUT_TMP" >&2; exit 5; fi
cp -f "$OUT_TMP" "$OUT_FINAL"
sha256sum "$OUT_FINAL" > "$WORKDIR/openwrt/bin/targets/rockchip/armv8/$(basename "$OUT_FINAL").sha256"
echo "Wrote $OUT_FINAL"
ls -lh "$OUT_FINAL"
sha256sum "$OUT_FINAL" | tee "$WORKDIR/make-sdcard-checksum.txt"
