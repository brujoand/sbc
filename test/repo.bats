#!/usr/bin/env bats

load test_helper

@test "repo::import fails with empty parameters" {
  source "${SBC_PATH}/src/repo.bash"
  run repo::import "" ""
  [ "$status" -eq 1 ]
}

@test "repo::import fails with missing repo_name" {
  source "${SBC_PATH}/src/repo.bash"
  run repo::import "" "http://example.com"
  [ "$status" -eq 1 ]
}

@test "repo::import fails with missing repo_url" {
  source "${SBC_PATH}/src/repo.bash"
  run repo::import "test_repo" ""
  [ "$status" -eq 1 ]
}
