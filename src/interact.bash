function _sbc_print_usage {
  cat <<EOF
  Usage: sbc [command]

  Commands:
  sync              - Sync repos, cogs and settings
  help              - Show this help text
  list              - List all cogs and repos
  configure         - Opens the sbc config in \$EDITOR (${EDITOR:-'not set'})
EOF
}

function _sbc_require_argument {
  local argument=$1
  local name=$2

  if [[ -z $argument ]]; then
    echo "Value for required argument '$name' is missing"
    _sbc_print_usage && return 1
  fi
}

function _sbc_configure {
  if [[ -n $EDITOR ]]; then
    $EDITOR "${HOME}/.config/sbc/settings.conf"
  else
    echo 'No EDITOR set, unable to open config'
    echo "You can edit it here: ${HOME}/.config/sbc/settings.conf"
  fi
}

function _sbc_execute {
  (source "${SBC_PATH}/src/main.bash" && "$@")
}

function _sbc_sync {
  (source "${SBC_PATH}/src/main.bash" && repo::delete_all && configure::load_config)
}

function sbc {
  case $1 in
  'list')
    for repo in $(_sbc_execute repo::list); do
      printf '\n%s:\n' "$repo"
      _sbc_execute cog::list "$(basename "${repo}")"
    done
    ;;
  'sync') # Reload settings and SBC
    _sbc_sync
    ;;
  'configure')
    _sbc_configure
    ;;
  *)
    _sbc_print_usage && return 1
    ;;
  esac
}

function _sbc {
  local cur words
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"

  words=()
  case "$prev" in
  'sbc')
    words=('sync' 'help' 'list' 'configure')
    ;;
  esac

  mapfile -t COMPREPLY < <(compgen -W "${words[*]}" -- "$cur")
}

complete -F _sbc sbc

_sbc_execute configure::load_config
# shellcheck source=/dev/null
source "$SBC_COGS"
