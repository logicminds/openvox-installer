#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ This script must be run as root." >&2
  exit 1
fi

CREATE_SYMLINKS="${3:-y}"
AGENT_VERSION="${1:-8}"
PKG_NAME="${2:-openvox-agent}"
BASE_URL="https://apt.voxpupuli.org"

. /etc/os-release
DISTRO="${ID,,}"
VERSION_ID_CLEAN=$(echo "$VERSION_ID" | cut -d. -f1,2)

case "$DISTRO" in
  ubuntu)
    RELEASE_FILE="openvox${AGENT_VERSION}-release-ubuntu${VERSION_ID_CLEAN}.deb"
    ;;
  debian)
    RELEASE_FILE="openvox${AGENT_VERSION}-release-debian${VERSION_ID_CLEAN}.deb"
    ;;
  *)
    echo "❌ Unsupported distro: $DISTRO"
    exit 1
    ;;
esac

curl -fsSL "$BASE_URL/$RELEASE_FILE" -o /tmp/openvox-release.deb
dpkg -i /tmp/openvox-release.deb
rm /tmp/openvox-release.deb

curl -fsSL "$BASE_URL/openvox-keyring.gpg" > /usr/share/keyrings/openvox-archive-keyring.gpg

apt update
apt install -y "$PKG_NAME"

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
