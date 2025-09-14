#! /usr/bin/env bash

# This file is used to seperate all the below sourced
# files from the runtime environment

# Source SBC standard library for utilities and logging
# shellcheck source=cogs/library.sh
source "${SBC_PATH}/src/cogs/library.sh"
source "${SBC_PATH}/src/configure.bash"
source "${SBC_PATH}/src/repo.bash"
source "${SBC_PATH}/src/cog.bash"
