#!/usr/bin/env bash

SBL_LOG_FORMAT=${SBL_LOG_FORMAT:-color}
SBL_LOG_LEVEL=${SBL_LOG_LEVEL:-INFO}

function sbl::log::info {
  sbl::log::_write_log "INFO" "$@"
}

function sbl::log::debug {
  sbl::log::_write_log "DEBUG" "$@"
}

function sbl::log::warn {
  sbl::log::_write_log "WARN" "$@"
}

function sbl::log::error {
  sbl::log::_write_log "ERROR" "$@"
  local stack_offset=1
  printf '%s:\n' 'Stacktrace:' >&2
  for stack_id in "${!FUNCNAME[@]}"; do
    if [[ $stack_offset -le $stack_id ]]; then
      local source_file="${BASH_SOURCE[$stack_id]}"
      local function="${FUNCNAME[$stack_id]}"
      local line="${BASH_LINENO[$((stack_id - 1))]}"
      printf '  %s:%s:%s\n' "$source_file" "$function" "$line" >&2
    fi
  done
}

function sbl::log::level_is_active {
  local check_level current_level
  check_level=$1

  declare -A log_levels=(
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
  )

  check_level="${log_levels["$check_level"]}"
  current_level="${log_levels["$SBL_LOG_LEVEL"]}"

  ((check_level >= current_level))
}

function sbl::log::get_color_code_for_level {
  local level=$1

  declare -A log_colors=(
    ['DEBUG']=34 # blue
    ['INFO']=32  # green
    ['WARN']=33  # yellow
    ['ERROR']=31 # red
  )

  printf '%s' "${log_colors[$level]}"
}

function sbl::log::_write_log {
  local timestamp file function_name log_level
  log_level=$1
  # Shift away the first argument so '$@' becomes words to log
  shift

  if sbl::log::level_is_active "$log_level"; then
    timestamp=$(date +'%y.%m.%d %H:%M:%S')
    file="${BASH_SOURCE[2]##*/}"
    function_name="${FUNCNAME[2]}"
    case "$SBL_LOG_FORMAT" in
    color)
      color_code=$(sbl::log::get_color_code_for_level "$log_level")
      >&2 printf '%s [%s] [%s] [%s - %s]: \e[%sm%s\e[0m\n' \
        "$log_level" "$HOSTNAME" "$timestamp" "$file" "$function_name" "$color_code" "${*}"
      ;;
    no_color)
      >&2 printf '%s [%s] [%s] [%s - %s]: %s\n' \
        "$log_level" "$HOSTNAME" "$timestamp" "$file" "$function_name" "${*}"
      ;;
    json)
      >&2 printf '{"timestamp": "%s", "level": "%s", "script": "%s", "function": "%s", "host": "%s", "message": "%s"}\n' \
        "$timestamp" "$log_level" "$file" "$function_name" "$HOSTNAME" "${*}"
      ;;
    esac
  fi
}
