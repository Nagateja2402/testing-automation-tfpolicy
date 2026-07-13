# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_func_plugin_count_substring.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_s3_bucket" "pass_no_dots" {
  expect_failure = false
  attrs = { bucket = "regression-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "pass_at_limit" {
  expect_failure = false
  attrs = { bucket = "a.b.c.d" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_over_limit" {
  expect_failure = true
  attrs = { bucket = "a.b.c.d.e.f" }
  meta  = { provider_type = "aws" }
}
