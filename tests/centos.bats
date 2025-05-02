#!/usr/bin/env bats

load ./common.bash

@test "Install openvox-agent on CentOS" {
  run bash -c 'curl -fsSL https://voxpupuli.org/install.sh | bash -s -- 8 openvox-agent'
  assert_success
  run rpm -q openvox-agent
  assert_success
}

@test "puppet should be in PATH" {
  run command -v puppet
  assert_success
  assert_output --partial "/usr/local/bin/puppet"
}

@test "puppet version should return a valid version" {
  run puppet version
  assert_success
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
