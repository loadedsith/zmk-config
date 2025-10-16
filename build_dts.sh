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

# Git in container thinks workspace ownership is “dubious”
git config --global --add safe.directory /github/workspace
git config --global --add safe.directory /github/workspace/zephyr
git config --global --add safe.directory '*'

# West setup and build
west init -l config
west update
west build -s zmk/app -b "${BOARD}" -- \
  -DSHIELD="${SHIELD_RIGHT} ${EXTRA_SHIELD}" \
  -DDTC_OVERLAY_FILE="${OVERLAY_PATH}"

# List outputs for debugging
ls -la build/zephyr || true
