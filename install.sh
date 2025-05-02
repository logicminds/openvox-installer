#!/usr/bin/env bash
set -euo pipefail

AGENT_VERSION="${1:-8}"
PKG_NAME="${2:-openvox-agent}"

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS_ID="${ID,,}"
else
  echo "❌ Could not determine OS from /etc/os-release"
  exit 1
fi

case "$OS_ID" in
  ubuntu|debian)
    INSTALL_SCRIPT_URL="https://voxpupuli.org/install-openvox.sh"
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
echo "📥 Downloading installer from: $INSTALL_SCRIPT_URL"
curl -fsSL "$INSTALL_SCRIPT_URL" | bash -s -- "$AGENT_VERSION" "$PKG_NAME"
