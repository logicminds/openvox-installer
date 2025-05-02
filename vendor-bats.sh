#!/usr/bin/env bash
# Purpose: This script sets up the Bats testing dependencies for running tests in a Docker container.
# This is already included in this repo but is here for convenience if needing to update

mkdir -p tests/test_helper

if [ ! -d tests/test_helper/bats-support ]; then
  echo "📥 Cloning bats-support..."
  git clone --depth=1 https://github.com/bats-core/bats-support tests/test_helper/bats-support
else
  echo "✅ bats-support already exists. Skipping clone."
fi

if [ ! -d tests/test_helper/bats-assert ]; then
  echo "📥 Cloning bats-assert..."
  git clone --depth=1 https://github.com/bats-core/bats-assert tests/test_helper/bats-assert
else
  echo "✅ bats-assert already exists. Skipping clone."
fi
rm -rf tests/test_helper/bats-support/.git
rm -rf tests/test_helper/bats-assert/.git
