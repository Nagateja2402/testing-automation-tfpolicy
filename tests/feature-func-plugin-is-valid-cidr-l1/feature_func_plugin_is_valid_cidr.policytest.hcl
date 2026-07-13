# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_func_plugin_is_valid_cidr.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_security_group" "pass_all_valid" {
  expect_failure = false
  attrs = {
    ingress = [
      { cidr = "10.0.0.0/8" },
      { cidr = "192.168.1.0/24" },
    ]
  }
  meta = { provider_type = "aws" }
}

resource "aws_security_group" "fail_malformed_cidr" {
  expect_failure = true
  attrs = {
    ingress = [
      { cidr = "10.0.0.0/8" },
      { cidr = "not-a-cidr" },
      { cidr = "256.256.256.256/32" },
    ]
  }
  meta = { provider_type = "aws" }
}
