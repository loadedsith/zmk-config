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

# Convert overlay path to absolute
OVERLAY_PATH="$(realpath "${OVERLAY_PATH}")"

# Sanity checks
test -f "${OVERLAY_PATH}"
test -f config/west.yml

# Follow the exact steps from zmkfirmware/zmk/.github/workflows/build-user-config.yml
west init -l config
west update
west zephyr-export

# Build following ZMK workflow pattern:
# west build -s zmk/app -b BOARD -- -DZMK_CONFIG=path -DSHIELD="shields" cmake-args
west build -s zmk/app -b "${BOARD}" -- \
  -DZMK_CONFIG="${PWD}/config" \
  -DSHIELD="${SHIELD_RIGHT} ${EXTRA_SHIELD}" \
  -DEXTRA_DTC_OVERLAY_FILE="${OVERLAY_PATH}"

# List outputs for debugging
ls -la build/zephyr || true
