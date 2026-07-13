# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_func_plugin_sha256_hex.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "regression-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "pass_empty" {
  expect_failure = false
  attrs = { bucket = "" }
  meta  = { provider_type = "aws" }
}
