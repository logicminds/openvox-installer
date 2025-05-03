#!/usr/bin/env bats

load ./common.bash

@test "puppet should be in PATH" {
  run command -v puppet
  assert_success
  assert_output --partial "/usr/local/bin/puppet"
}

@test "puppet version should return a valid version" {
  run puppet --version
  assert_success
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
