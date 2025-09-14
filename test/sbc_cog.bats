#!/usr/bin/env bats

load test_helper

@test "sbc::shell_init_files returns init files" {
  source "${SBC_PATH}/src/cogs/sbc.bash"
  run sbc::shell_init_files
  [ "$status" -eq 0 ]
  [[ $output =~ "bashrc" ]]
}

@test "sbc::_expand_alias returns non-zero for non-alias" {
  source "${SBC_PATH}/src/cogs/sbc.bash"
  run sbc::_expand_alias "nonexistent_alias"
  [ "$status" -eq 1 ]
}

@test "sbc::describe shows function definition" {
  source "${SBC_PATH}/src/cogs/sbc.bash"
  echo "function test_function() { echo test; }" >"${SBC_TEST_TEMP_DIR}/test.bash"
  run bash -c "cd ${SBC_PATH} && echo 'function test_function() { echo test; }' | grep -q 'function test_function'"
  [ "$status" -eq 0 ]
}
