#!/usr/bin/env bats

load test_helper

@test "cog::verify_path returns 0 for existing file" {
  source "${SBC_PATH}/src/cog.bash"
  echo "test" >"${SBC_TEST_TEMP_DIR}/test_cog.bash"
  run cog::verify_path "${SBC_TEST_TEMP_DIR}/test_cog.bash"
  [ "$status" -eq 0 ]
}

@test "cog::verify_path returns 1 for non-existing file" {
  source "${SBC_PATH}/src/cog.bash"
  run cog::verify_path "/nonexistent/file.bash"
  [ "$status" -eq 1 ]
}

@test "cog::enable adds cog to SBC_COGS file" {
  source "${SBC_PATH}/src/cog.bash"
  mkdir -p "${SBC_TEST_TEMP_DIR}/test_repo"
  echo "function test_func() { echo test; }" >"${SBC_TEST_TEMP_DIR}/test_repo/test_cog.bash"
  export SBC_REPO_PATH="${SBC_TEST_TEMP_DIR}"
  run cog::enable "test_repo/test_cog"
  [ "$status" -eq 0 ]
  grep -q "test_repo/test_cog.bash" "$SBC_COGS"
}
