#! /usr/bin/env bash

debug::log() {
  local timestamp file function
  timestamp=$(date +'%y.%m.%d %H:%M:%S')
  file="${BASH_SOURCE[1]##*/}"
  function="${FUNCNAME[1]}"
  >&2 printf '\n[%s] [%s - %s]: \e[31m%s\e[0m\n' "$timestamp" "$file" "$function" "${*}"
}
