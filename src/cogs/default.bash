#!/usr/bin/env bash

_expand_alias() {
  local alias_name alias_definition
  alias_name=$1
  [[ -z $alias_name ]] && return 1
  type "$alias_name" &>/dev/null || return 1
  alias_definition=$(alias "$alias_name")
  dequote "${alias_definition//alias ${alias_name}=}"
}

_update_comp_words() {
  local alias_name alias_value
  alias_name=$1
  alias_value=$2
  [[ -z $alias_name || -z $alias_value ]] && return 1

  local alias_value_array
  read -r -a alias_value_array <<< "$alias_value"
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


function _alias_completion_wrapper() {
  local alias_name alias_definition alias_value
  alias_name=${COMP_WORDS[0]}
  alias_value="$(_expand_alias "$alias_name")"
  [[ -z $alias_value ]] && return 1

  _update_comp_words "$alias_name" "$alias_value"
  # Update other COMP variables
  COMP_LINE=${COMP_LINE//${alias_name}/${alias_value}}
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
  COMP_POINT=${#COMP_LINE}

  local previous_word current_word
  current_word=${COMP_WORDS[$COMP_CWORD]}
  if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
    previous_word=${COMP_WORDS[$(( COMP_CWORD - 1 ))]}
  fi
  local command=${COMP_WORDS[0]}
  comp_definition=$(complete -p "$command")
  comp_function=$(sed -n "s/^complete .* -F \(.*\) ${command}/\1/p" <<< "$comp_definition")

  # Call the original completion script with our expanded alias
  "$comp_function" "${command}" "${current_word}" "${previous_word}"
}


function _sourced_files(){ # Recursive helper for sourced_files
  local root_file=$1
  local source_file
  while read -r source_file; do
    source_file=$(eval echo "$source_file")
    if [[ -f "$source_file" ]]; then
      printf '%s\n' "$source_file"
      _sourced_files "$source_file"
    fi
  done < <(sed -En 's/^[.|source]+ (.*)/\1/p' "$root_file")
}

function sourced_files() { # Lists files which would be sourced
  local init_file
  init_file=$(shell_init_file)
  printf '%s\n' "$init_file"
  _sourced_files "$init_file"
}

function sourced_functions() { # List all functions which would be sourced
  for file in $(sourced_files); do
    sed -n "s/^function \(.*\)() { \(.*\)$/\1 \2/p" "$file" | grep -v "^_"
  done | sort
}

function sourced_aliases() { # List all aliases which would be sourced
  for file in $(sourced_files); do
    sed -n "s/.*alias \(.*\)=['|\"].*#\(.*\)$/\1 #\2/p" "$file" | sed "s/sourced_aliases=.*#/sourced_aliases #/"
  done | sort
}

function shell_init_file() { # Returns what would be the initial sourced file
  local init_locations init_file
  init_locations=( "$HOME"/.{bashrc,bash_profile,bash_login,profile} )
  if [[ $- == *i* ]]; then
    init_file="${HOME}/.bashrc"
  else
    for candidate in "${init_locations[@]}"; do
      if [[ -f "$candidate" ]]; then
        init_file="$candidate"
        break
      fi
    done
  fi

  if [[ -z $init_file ]]; then
    echo "Could not find any config files.."
    exit 1
  else
    echo "$init_file"
  fi
}

function edit_shell_config() { # Edit a shell config file
  local file
  file=$(grep "/$1$" <(sourced_files))
  "${EDITOR:-vi}" "$file"
}

function _edit_shell_config() { # Fuzzy tabcompletion for edit_shell_config
  local cur config_files
  _get_comp_words_by_ref cur
  config_files=$(for file in $(sourced_files); do echo "${file##*/}"; done)

  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$config_files" ) )
  else
    COMPREPLY=( $(grep -i "$cur" <<< "$config_files" ) )
  fi
}

complete -o nospace -F _edit_shell_config edit_shell_config


function describe() { # show help and location of a custom function or alias
  local query pp
  query="$1"
  pp="cat"
  if [[ -n "$(type bat 2> /dev/null)" ]]; then
    pp="bat -l bash -p"
  fi

  type="$(type -t "$query")"

  for file in $(sourced_files); do
    awk '/^function '"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file"
    awk '/^function \_'"$query"'\(\)/,/^}/ { i++; if(i==1){print "# " FILENAME ":" FNR RS $0;} else {print $0;}}' "$file"
    awk '/^alias '"$query"'=/,/$/ {print "# " FILENAME ":" FNR RS $0 RS;}' "$file"
  done | $pp
  complete -p "$query" 2> /dev/null
}

function _describe() { # Completion for describe
  local cur words
  _get_comp_words_by_ref cur
  words=$(sourced_aliases; sourced_functions | cut -d ' ' -f 1)
  COMPREPLY=( $( compgen -W "$words" -- "$cur") )
}

complete -o nospace -F _describe describe

alias halp='echo -e "Sourced files:\n$(sourced_files | sed "s#$HOME/#~/#")\n # \nFunctions:\n$(sourced_functions)\n # \nAliases:\n\n$(sourced_aliases)" | column -t -s "#"' # Show all custom aliases and functions
