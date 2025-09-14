#!/usr/bin/env bash

sbc::_expand_alias() {
  local alias_name alias_definition
  alias_name=$1
  [[ -z $alias_name ]] && return 1
  type "$alias_name" &>/dev/null || return 1
  alias_definition=$(alias "$alias_name")
  sbl::utils::dequote "${alias_definition//alias ${alias_name}=/}"
}

sbc::_update_comp_words() {
  local alias_name alias_value
  alias_name=$1
  alias_value=$2
  [[ -z $alias_name || -z $alias_value ]] && return 1

  local alias_value_array
  read -r -a alias_value_array <<<"$alias_value"
  local comp_words=()

  for word in "${COMP_WORDS[@]}"; do
    if [[ $word == "$alias_name" ]]; then
      comp_words+=("${alias_value_array[@]}")
    else
      comp_words+=("$word")
    fi
  done

  COMP_WORDS=("${comp_words[@]}")
}

function sbc::_alias_completion_wrapper() {
  local alias_name alias_definition alias_value
  alias_name=${COMP_WORDS[0]}
  alias_value="$(sbc::_expand_alias "$alias_name")"
  [[ -z $alias_value ]] && return 1

  sbc::_update_comp_words "$alias_name" "$alias_value"
  COMP_LINE=${COMP_LINE//${alias_name}/${alias_value}}
  COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
  COMP_POINT=${#COMP_LINE}

  local previous_word current_word
  current_word=${COMP_WORDS[$COMP_CWORD]}
  if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
    previous_word=${COMP_WORDS[$((COMP_CWORD - 1))]}
  fi
  local command=${COMP_WORDS[0]}
  comp_definition=$(complete -p "$command")
  comp_function=$(sed -n "s/^complete .* -F \(.*\) ${command}/\1/p" <<<"$comp_definition")

  "$comp_function" "${command}" "${current_word}" "${previous_word}"
}

function sbc::_sourced_files() {
  local root_file=$1
  local source_file
  while read -r source_file; do
    source_file=$(eval echo "$source_file")
    if [[ -f $source_file ]]; then
      printf '%s\n' "$source_file"
      sbc::_sourced_files "$source_file"
    fi
  done < <(sed -En 's/^[[:space:]]*[.|source][[:space:]]+(.*)/\1/p' "$root_file")
}

function sbc::sourced_files() {
  local init_files
  for init_file in $(sbc::shell_init_files); do
    printf '%s\n' "$init_file"
    sbc::_sourced_files "$init_file"
  done
}

function sbc::sourced_functions() {
  for file in $(sbc::sourced_files); do
    sed -n "s/^function \(.*\)() { \(.*\)$/\1 \2/p" "$file" | grep -v "^_"
  done | sort
}

function sbc::sourced_aliases() {
  for file in $(sbc::sourced_files); do
    sed -n "s/.*alias \(.*\)=['|\"].*#\(.*\)$/\1 #\2/p" "$file" | sed "s/sourced_aliases=.*#/sourced_aliases #/"
  done | sort
}

function sbc::shell_init_files() {
  local non_login_files login_files login_candidates init_files
  init_files=()
  non_login_files=("${HOME}/.bashrc" "/etc/bash.bashrc")
  login_files=("/etc/profile")
  login_candidates=("$HOME"/.{bash_profile,bash_login,profile})
  if shopt -q login_shell; then
    init_files+=("${login_files[@]}")
    for candidate in "${login_candidates[@]}"; do
      if [[ -f $candidate ]]; then
        init_files+=("$candidate")
        break
      fi
    done
  else
    init_files+=("${non_login_files[@]}")
  fi

  printf '%s\n' "${init_files[@]}"
}

function sbc::edit_shell_config() {
  local file
  file=$(grep "/$1$" <(sbc::sourced_files))
  "${EDITOR:-vi}" "$file"
}

function sbc::_edit_shell_config() {
  local cur config_files
  _get_comp_words_by_ref cur
  config_files=$(for file in $(sbc::sourced_files); do echo "${file##*/}"; done)

  if [[ -z $cur ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$config_files")
  else
    mapfile -t COMPREPLY < <(grep -i "$cur" <<<"$config_files")
  fi
}

complete -o nospace -F sbc::_edit_shell_config sbc::edit_shell_config

function sbc::describe() {
  local query pp
  query="$1"
  pp="cat"
  if [[ -n "$(type bat 2>/dev/null)" ]]; then
    pp="bat -l bash -p"
  fi

  for file in $(sbc::sourced_files); do
    awk '/^function '"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file"
    awk '/^function \_'"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file"
    awk '/^alias '"$query"'=/,/$/ {print "# " FILENAME ":" FNR RS $0 RS;}' "$file"
  done | $pp
  complete -p "$query" 2>/dev/null
}

function sbc::_describe() {
  local cur words
  _get_comp_words_by_ref cur
  words=$(
    sbc::sourced_aliases
    sbc::sourced_functions | cut -d ' ' -f 1
  )
  mapfile -t COMPREPLY < <(compgen -W "$words" -- "$cur")
}

complete -o nospace -F sbc::_describe sbc::describe

alias halp='echo -e "Sourced files:\n$(sbc::sourced_files | sed "s#$HOME/#~/#")\n # \nFunctions:\n$(sbc::sourced_functions)\n # \nAliases:\n\n$(sbc::sourced_aliases)" | column -t -s "#"'
