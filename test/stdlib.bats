#!/usr/bin/env bats

load test_helper

@test "sbl::utils::dequote removes quotes" {
  result=$(sbl::utils::dequote '"test"')
  [ "$result" = "test" ]
}

@test "sbl::utils::dequote removes single quotes" {
  result=$(sbl::utils::dequote "'test'")
  [ "$result" = "test" ]
}

@test "sbl::utils::create_temp_file creates file" {
  temp_file=$(sbl::utils::create_temp_file)
  [ -f "$temp_file" ]
}

@test "sbl::utils::create_temp_dir creates directory" {
  temp_dir=$(sbl::utils::create_temp_dir)
  [ -d "$temp_dir" ]
}

@test "sbl::log::debug writes to stderr" {
  export SBL_LOG_LEVEL=DEBUG
  run bash -c "cd ${SBC_PATH}; source src/cogs/library.sh; sbl::log::debug 'test message' 2>&1"
  [[ $output =~ "test message" ]]
}
