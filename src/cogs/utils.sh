#!/usr/bin/env bash

SBL_TMP_FILE="/tmp/library_tmp_files_${BASHPID}"

function sbl::utils::_clean_tmp_files {
  [[ -f $SBL_TMP_FILE ]] || return 0
  while read -r tmp_file; do
    if [[ -f ${tmp_file} || -d ${tmp_file} ]]; then
      sbl::log::debug "Cleaning out temp file: ${tmp_file}"
      rm -rf "$tmp_file"
    else
      sbl::log::debug "Temp file ${tmp_file} already deleted"
    fi
  done <"${SBL_TMP_FILE}"
  rm -f "$SBL_TMP_FILE"
}

if [[ -z ${DISABLE_TRAPS-} ]]; then
  trap 'sbl::utils::_clean_tmp_files' EXIT
fi

function sbl::utils::delete_file_on_exit {
  file=$1
  echo "$file" >>"${SBL_TMP_FILE}"
}

function sbl::utils::create_temp_dir {
  sbl::utils::create_temp_file "-d" "${@}"
}

function sbl::utils::create_temp_file {
  local temp_file
  temp_file="$(mktemp "${@}")"
  sbl::utils::delete_file_on_exit "$temp_file"
  printf '%s' "$temp_file"
}

function sbl::utils::require_variable {
  local variable_name=$1
  local variable_value="${!1}"

  if [[ -z $variable_value || $variable_value == "" ]]; then
    sbl::log::error "Variable ${variable_name} was required, but was not provided"
    return 1
  fi
}

function sbl::utils::require_sudo {
  if [[ "$(sudo whoami 2>/dev/null)" != 'root' ]]; then
    sbl::log::info "Unable to attain sudo privileges, can not proceed"
    return 1
  fi
}

function sbl::utils::retries_for_command {
  local retries=$1
  sbl::utils::require_variable retries
  shift
  local command=("${@}")
  [[ ${#command[@]} -eq 0 ]] && return 1
  local tries=1

  while [[ $tries -le $retries ]]; do
    "${command[@]}" && break
    sbl::log::warn "Attempt {$tries} of ${retries} failed"
    tries=$((tries + 1))
    sleep 1
  done
}

function sbl::utils::dequote() {
  local input="$1"
  # Remove single or double quotes from beginning and end
  input="${input#\"}" # Remove leading double quote
  input="${input%\"}" # Remove trailing double quote
  input="${input#\'}" # Remove leading single quote
  input="${input%\'}" # Remove trailing single quote
  printf '%s' "$input"
}
