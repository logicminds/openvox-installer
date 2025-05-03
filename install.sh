#!/usr/bin/env bash
set -euo pipefail

AGENT_VERSION="${1:-8}"
PKG_NAME="${2:-openvox-agent}"

# macOS detection
if [[ "$(uname)" == "Darwin" ]]; then
  echo "🍎 Detected macOS"
  INSTALL_SCRIPT_URL="https://voxpupuli.org/install-openvox-mac.sh"
  echo "📥 Downloading macOS installer from: $INSTALL_SCRIPT_URL"
  curl -fsSL "$INSTALL_SCRIPT_URL" | bash -s -- "$AGENT_VERSION" "$PKG_NAME"
  exit 0
fi

# Linux OS detection
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS_ID="${ID,,}"
else
  echo "❌ Could not determine OS from /etc/os-release"
  exit 1
fi

case "$OS_ID" in
  ubuntu|debian)
    INSTALL_SCRIPT_URL="https://voxpupuli.org/install-openvox-deb.sh"
    ;;
  rhel|centos|rocky|almalinux|fedora|amzn|sles)
    INSTALL_SCRIPT_URL="https://voxpupuli.org/install-openvox-rpm.sh"
    ;;
  *)
    echo "❌ Unsupported OS: $OS_ID"
    exit 1
    ;;
esac

echo "🔍 Detected OS: $OS_ID"
echo "📥 Downloading Linux installer from: $INSTALL_SCRIPT_URL"
curl -fsSL "$INSTALL_SCRIPT_URL" | bash -s -- "$AGENT_VERSION" "$PKG_NAME"
if [[ -f /opt/puppetlabs/bin/puppet ]]; then
  echo "🎉 OpenVox agent installed successfully."
else
  echo "❌ OpenVox agent installation failed."
  exit 1
fi