#! /usr/bin/env bash

#################################
#   Simple Bash Cogs (SBC)      #
#################################

# Source SBC standard library for utilities and logging
# shellcheck source=src/cogs/library.sh
source "${SBC_PATH}/src/cogs/library.sh"
SBC_COGS="$(sbl::utils::create_temp_file)"

# shellcheck source=src/interact.bash

export SBC_COGS
export SBC_PATH
source "${SBC_PATH}/src/interact.bash"
export SBC_SOURCED=1
