#!/usr/bin/env bash
# Usage: build_dts.sh <shield_right> <extra_shield> <overlay_path> <board>
# Example: build_dts.sh waterfowl_right nice_oled config/waterfowl_right.overlay nice_nano_v2
set -euo pipefail
IFS=$'\n\t'
set -x

SHIELD_RIGHT="${1:-waterfowl_right}"
EXTRA_SHIELD="${2:-nice_oled}"
OVERLAY_PATH="${3:-config/waterfowl_right.overlay}"
BOARD="${4:-nice_nano_v2}"

# Sanity checks
test -f "${OVERLAY_PATH}"
test -f config/west.yml

echo "=== Current directory: $(pwd)"
echo "=== Directory listing:"
ls -la

# Git in container thinks workspace ownership is "dubious"
git config --global --add safe.directory '*'

# West setup and build
echo "=== Initializing west workspace..."
west init -l config

echo "=== West manifest status:"
cat .west/config || true

echo "=== Running west update..."
west update

echo "=== West update completed, verifying..."

echo "=== Checking workspace structure:"
ls -la

echo "=== Checking if zmk directory exists:"
ls -la zmk/ || echo "zmk directory not found!"

echo "=== Checking if zephyr exists at workspace root:"
ls -la zephyr/ || echo "zephyr not found!"

echo "=== Setting up Zephyr environment..."
export ZEPHYR_BASE="$(pwd)/zephyr"
echo "ZEPHYR_BASE=${ZEPHYR_BASE}"

echo "=== Building..."
west build -s zmk/app -b "${BOARD}" -- \
  -DSHIELD="${SHIELD_RIGHT} ${EXTRA_SHIELD}" \
  -DDTC_OVERLAY_FILE="${OVERLAY_PATH}"

# List outputs for debugging
ls -la build/zephyr || true
