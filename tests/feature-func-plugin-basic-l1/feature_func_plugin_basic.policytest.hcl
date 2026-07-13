# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_plugin_basic
# Asserts        : plugin function returns expected value
# =============================================================================

policytest {
  targets = ["feature_func_plugin_basic.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
