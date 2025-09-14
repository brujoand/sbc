#!/usr/bin/env bash

if [[ -z ${SBC_STDLIB_SOURCED-} ]]; then
  SBC_COGS_DIR="${SBC_PATH}/src/cogs"
  source "${SBC_COGS_DIR}/utils.sh"
  source "${SBC_COGS_DIR}/log.sh"
fi

SBC_STDLIB_SOURCED=1
