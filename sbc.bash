#! /usr/bin/env bash

#################################
#   Simple Bash Cogs (SBC)      #
#################################

# shellcheck source=src/interact.bash

if [[ -d "/run/user/${UID}" ]]; then
  SBC_COGS="$(mktemp --tmpdir="/run/user/${UID}")" && trap 'command rm "$SBC_COGS"' EXIT;
else
  SBC_COGS="$(mktemp)" && trap 'command rm "$SBC_COGS"' EXIT;
fi

export SBC_COGS
export SBC_PATH
source "${SBC_PATH}/src/interact.bash"
