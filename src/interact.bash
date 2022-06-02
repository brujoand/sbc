_sbc_print_usage() {
  cat << EOF
  Usage: sbc [command]

  Commands:
  sync              - Sync repos, cogs and settings
  help              - Show this help text
  repo
    list            - List all repos
    import          - Import a repo, takes file/git url and name as parameter
    remove          - Remove repo, takes repo name as parameter
  cog
    list            - List all cogs
    load            - Load a cog by repo_name/cog_name
  configure         - Opens the sbc config in \$EDITOR (${EDITOR:-'not set'})
EOF
}

_sbc_require_argument() {
  local argument=$1
  local name=$2

  if [[ -z "$argument" ]]; then
    echo "Value for required argument '$name' is missing"
    _sbc_print_usage && return 1
  fi
}

_sbc_sync() {
  _sbc_execute configure::load_config
  # shellcheck source=/dev/null
  source "$SBC_COGS"
}

_sbc_configure() {
  if [[ -n "$EDITOR" ]]; then
    $EDITOR "${HOME}/.config/sbc/settings.conf"
  else
    echo "No \$EDITOR set, unable to open config"
    echo "You can edit it here: ${HOME}/.config/sbc/settings.conf"
  fi
}

_sbc_wrap() {
  if [[ $SBC_DEBUG == 'true' ]]; then
    set -T
    log_function() {
      [[ ${BASH_LINENO[0]} -eq 0 ]] && return
      >&2 echo "${0}:${BASH_LINENO[0]} - ${FUNCNAME[1]}"
    }
    trap 'log_function' DEBUG
  fi

  source "${SBC_PATH}/src/main.bash"
}

_sbc_execute() {
  (_sbc_wrap && "$@")
}

sbc() {
  case $1 in
    'repo')
      case $2 in
        'list')
          _sbc_execute repo::list
          ;;
        'import')
          _sbc_require_argument "$3" '[repo_url]'
          _sbc_execute repo::import "$3"
          ;;
        'remove')
          _sbc_require_argument "$3" '[repo_url]'
          _sbc_execute repo::remove "$3"
          ;;
        'update')
          _sbc_execute repo::update
          _sbc_sync
          ;;
        *)
          _sbc_print_usage && return 1
          ;;
      esac
      ;;
    'cog')
      case $2 in
        'list')
          _sbc_require_argument "$3" '[repo_name]'
          _sbc_execute cog::list "$3"
          ;;
        'load')
          _sbc_require_argument "$3" '[repo_name]'
          _sbc_execute cog::load "$3"
          ;;
        *)
          _sbc_print_usage && return 1
          ;;
      esac
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

_sbc() {
  local cur words
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[$(( COMP_CWORD - 1 ))]}"

  words=()
  case "$prev" in
    'repo')
      words=('update' 'list' 'import' 'remove')
      ;;
    'cog')
      words=('list' 'load')
      ;;
    'sbc')
      words=('repo' 'cog' 'sync' 'help' 'status' 'configure')
      ;;
  esac

  COMPREPLY=( $( compgen -W "${words[*]}" -- "$cur") )
}

complete -F _sbc sbc

