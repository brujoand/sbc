#!/usr/bin/env bash

repo::import() {
  local repo_name="$1"
  local repo_url="$2"

  if [[ -z "$repo_url" || -z "$repo_name" ]]; then
    debug::log "Unable to add repo with name: '${repo_name}' and url: '${repo_url}'"
    return 1
  fi

  repo_path="${SBC_REPO_PATH}/${repo_name}"

  [[ -d "$repo_path" ]] && return 0

  if [[ -d "$repo_url" ]]; then
    repo_path="${SBC_REPO_PATH}/${repo_name}"
    ln -s "$repo_url" "$repo_path"
  elif [[ -f "${repo_path}/.git" ]]; then
    git clone "$repo_url" "$repo_path"
  else
    debug::log "Don't know how to import '$repo_name'"
    return 1
  fi

  debug::log "Successfully imported '$repo_name'"
}

repo::delete_all() {
  rm -rf "${SBC_REPO_PATH:?}/*"
}

repo::find_url() {
  local repo_path=$1
  if [[ -f "${repo_path}/.git" ]]; then
    cd "$repo_path" && git remote get-url origin
  elif [[ -L "$repo_path" ]]; then
    cd "${SBC_REPO_PATH}/$(readlink "$repo_path")" && pwd
  else
    echo "$repo_path"
  fi
}

repo::list() {
  shopt -s nullglob
  for repo in "${SBC_REPO_PATH}/"*; do
    printf '%s\n' "$repo"
  done
}
