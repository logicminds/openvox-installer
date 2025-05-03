#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ This script must be run as root." >&2
  exit 1
fi

CREATE_SYMLINKS="${3:-y}"
AGENT_VERSION="${1:-8}"
PKG_NAME="${2:-openvox-agent}"
BASE_URL="https://yum.voxpupuli.org"

. /etc/os-release
OS_ID="${ID,,}"
OS_VER_ID="${VERSION_ID%%.*}"

case "$OS_ID" in
  rhel|centos|rocky|almalinux)
    RPM_FILE="openvox${AGENT_VERSION}-release-el-${OS_VER_ID}.noarch.rpm"
    ;;
  amzn)
    case "$OS_VER_ID" in
      2)    RPM_FILE="openvox${AGENT_VERSION}-release-amazon-2.noarch.rpm" ;;
      2023) RPM_FILE="openvox${AGENT_VERSION}-release-amazon-2023.noarch.rpm" ;;
      *)    echo "❌ Unsupported Amazon version: $OS_VER_ID" && exit 1 ;;
    esac
    ;;
  fedora)
    RPM_FILE="openvox${AGENT_VERSION}-release-fedora-${OS_VER_ID}.noarch.rpm"
    ;;
  sles)
    RPM_FILE="openvox${AGENT_VERSION}-release-sles-${OS_VER_ID}.noarch.rpm"
    ;;
  *)
    echo "❌ Unsupported OS: $OS_ID"
    exit 1
    ;;
esac

curl -fsSL "$BASE_URL/$RPM_FILE" -o /tmp/openvox-release.rpm
rpm -Uvh /tmp/openvox-release.rpm
rm -f /tmp/openvox-release.rpm

yum install -y "$PKG_NAME"

BIN_DIR="/opt/puppetlabs/bin"
EXECUTABLES=(facter puppet pxp-agent)
if [[ ! "$CREATE_SYMLINKS" =~ ^[Yy]$ ]]; then
  read -rp "🔗 Symlink facter, puppet, and pxp-agent from $BIN_DIR to /usr/local/bin? [y/N]: " LINK_CHOICE
else
  LINK_CHOICE="$CREATE_SYMLINKS"
fi 
if [[ "$LINK_CHOICE" =~ ^[Yy]$ ]]; then
  for exe in "${EXECUTABLES[@]}"; do
    if [[ -x "$BIN_DIR/$exe" ]]; then
      ln -sf "$BIN_DIR/$exe" "/usr/local/bin/$exe"
      echo "✅ Linked $exe"
    fi
  done
else
  echo "⏭️ Skipping symlinks."
fi
