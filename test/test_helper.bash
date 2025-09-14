#!/usr/bin/env bash

export SBC_PATH="${BATS_TEST_DIRNAME}/.."
export SBC_LOG_LEVEL=DEBUG
source "${SBC_PATH}/src/cogs/library.sh"

setup() {
  local temp_dir
  temp_dir=$(sbl::utils::create_temp_dir)
  export SBC_TEST_TEMP_DIR="$temp_dir"
  export SBC_COGS="${SBC_TEST_TEMP_DIR}/test_cogs"
  touch "$SBC_COGS"
}
