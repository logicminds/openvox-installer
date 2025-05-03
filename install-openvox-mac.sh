#!/bin/bash
set -euo pipefail

DMG_URL="https://downloads.voxpupuli.org/mac/openvox8/15/arm64/openvox-agent-8.13.0-1.osx15.dmg"
MOUNT_POINT="/Volumes/openvox-agent"
TMP_DMG="/tmp/openvox-agent.dmg"
BIN_DIR="/opt/puppetlabs/bin"
LINK_DIR="/usr/local/bin"
EXECUTABLES=(puppet facter pxp-agent)

echo "📥 Downloading OpenVox agent .dmg..."
curl -fsSL "$DMG_URL" -o "$TMP_DMG"

echo "🔌 Mounting the disk image..."
hdiutil attach "$TMP_DMG" -mountpoint "$MOUNT_POINT" -nobrowse -quiet

PKG_PATH=$(find "$MOUNT_POINT" -name "*.pkg" | head -n 1)
if [[ -z "$PKG_PATH" ]]; then
  echo "❌ No .pkg found in mounted image." >&2
  hdiutil detach "$MOUNT_POINT" -quiet
  exit 1
fi

echo "📦 Installing package: $PKG_PATH"
sudo installer -pkg "$PKG_PATH" -target /

echo "🔋 Cleaning up disk image..."
hdiutil detach "$MOUNT_POINT" -quiet
rm -f "$TMP_DMG"

# Ask user if they want symlinks
read -rp "🔗 Do you want to symlink puppet, facter, and pxp-agent to /usr/local/bin? [Y/n]: " SYMLINK_CHOICE
SYMLINK_CHOICE="${SYMLINK_CHOICE:-Y}"

if [[ "$SYMLINK_CHOICE" =~ ^[Yy]$ ]]; then
  echo "🔗 Creating symlinks for binaries..."
  for exe in "${EXECUTABLES[@]}"; do
    SOURCE="$BIN_DIR/$exe"
    TARGET="$LINK_DIR/$exe"
    if [[ -x "$SOURCE" ]]; then
      sudo ln -sf "$SOURCE" "$TARGET"
      echo "✅ Linked $exe → $TARGET"
    else
      echo "⚠️  Skipping $exe (not found at $SOURCE)"
    fi
  done
else
  echo "⏭️  Skipping symlink creation."
fi

