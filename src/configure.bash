#! /usr/bin/env bash

SBC_CONFIG="${HOME}/.config/sbc"
config_file="${SBC_CONFIG}/settings.conf"
config_template="${SBC_PATH}/config/settings.conf.template"
default_config="${SBC_PATH}/config/settings.conf"
SBC_REPO_PATH="${SBC_CONFIG}/repos"

import_repo() {
  repo::import "$@"
}

enable_cog() {
  cog::enable "$@"
}

enable_cogs() {
  cog::enable_all "$@"
}

configure::ensure_config_exists() {
  [[ -d $SBC_REPO_PATH ]] || mkdir -p "$SBC_REPO_PATH"

  if [[ ! -f $config_file ]]; then
    sbl::log::debug "SBC config file not found: ${config_file}"
    sbl::log::debug "Creating it.."
    cp "$config_template" "$config_file"
  fi
}

configure::load_config() {
  configure::ensure_config_exists
  rm -f "$SBC_COGS"
  # shellcheck source=/dev/null
  [[ -f $default_config ]] && source "$default_config"
  # shellcheck source=/dev/null
  [[ -f $config_file ]] && source "$config_file"
}
