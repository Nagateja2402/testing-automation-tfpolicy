# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_func_plugin_cidr_contains_ip.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_instance" "pass_inside_range" {
  expect_failure = false
  attrs = { private_ip = "10.42.7.9" }
  meta  = { provider_type = "aws" }
}

resource "aws_instance" "pass_unset" {
  expect_failure = false
  attrs = {}
  meta  = { provider_type = "aws" }
}

resource "aws_instance" "fail_outside_range" {
  expect_failure = true
  attrs = { private_ip = "172.16.0.5" }
  meta  = { provider_type = "aws" }
}
