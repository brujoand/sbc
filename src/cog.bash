#!/usr/bin/env bash

cog::expand_cog_path() {
  local cog_name=$1
  printf '%s' "${SBC_REPO_PATH}/${cog_name}.bash"
}

cog::verify_path() {
  local cog_path=$1
  if [[ -f $cog_path ]]; then
    return 0
  else
    sbl::log::debug "Cog not found: $cog_path"
    return 1
  fi
}

cog::enable_all() {
  local repo=$1
  shopt -s nullglob
  for cog in "${SBC_REPO_PATH}/${repo}/"*.bash; do
    # TODO until better path is found
    cog::enable "${repo}/$(basename "$cog" .bash)"
  done
}

cog::enable() {
  local cog_path cog_name
  cog_name=$1
  cog_path=$(cog::expand_cog_path "$cog_name")

  if ! cog::verify_path "$cog_path"; then
    return 1
  fi

  [[ -f $SBC_COGS ]] || touch "$SBC_COGS"
  if ! grep -q "^source ${cog_path}$" "$SBC_COGS" 2>/dev/null; then
    printf '%s\n' "source ${cog_path}" >>"$SBC_COGS"
  fi
}

cog::load() {
  local cog_path cog_name
  cog_name=$1
  cog_path=$(cog::expand_cog_path "$cog_name")
  cog::enable "$cog_name"
  # shellcheck source=/dev/null
  source "$cog_path"
}

cog::list() {
  local repo=$1
  for cog in "${SBC_REPO_PATH}/${repo}/"*.bash; do
    printf '%s\n' "$(basename "$cog" .bash)"
  done
}
