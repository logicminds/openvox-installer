#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ubuntu:22.04}"
TEST_DIR="/test"
BATS_TEST_FILE=""

SUPPORTED_IMAGES=(
  "ubuntu:20.04"
  "ubuntu:22.04"
  "debian:11"
  "debian:12"
  "centos:7"
  "rockylinux:8"
  "rockylinux:9"
  "almalinux:8"
  "almalinux:9"
  "amazonlinux:2"
  "amazonlinux:2023"
  "fedora:40"
)

case "$IMAGE" in
  ubuntu:*|debian:*)
    BATS_TEST_FILE="ubuntu.bats"
    ;;
  centos:*|rockylinux:*|almalinux:*|amazonlinux:*|fedora:*)
    BATS_TEST_FILE="centos.bats"
    ;;
  *)
    echo "❌ Unsupported image: $IMAGE"
    echo "✅ Supported images:"
    for img in "${SUPPORTED_IMAGES[@]}"; do
      echo "   - $img"
    done
    exit 1
    ;;
esac

echo "🚀 Running local Bats test for: $IMAGE"
echo "docker run --rm -it -v \"$PWD\":\"$TEST_DIR\" --workdir \"$TEST_DIR\" $IMAGE bash"
  
  
docker run --rm -it \
  -v "$PWD":"$TEST_DIR" \
  --workdir "$TEST_DIR" \
  "$IMAGE" bash -c "
    set -e
    echo '📦 Installing dependencies...'
    if command -v apt-get >/dev/null; then
      apt-get update && apt-get install -y curl gnupg lsb-release python3 git
    elif command -v dnf >/dev/null; then
      dnf install -y curl gnupg2 redhat-lsb-core python3 git
    elif command -v yum >/dev/null; then
      yum install -y curl gnupg2 redhat-lsb-core python3 git
    fi

    echo '🧪 Installing Bats...'
    git clone --depth 1 https://github.com/bats-core/bats-core /opt/bats
    /opt/bats/install.sh /usr/local

    echo '🔬 Running test: tests/$BATS_TEST_FILE'
    bats tests/$BATS_TEST_FILE
  "
