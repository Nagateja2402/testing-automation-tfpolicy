# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_toplevel_plugin_block
# Asserts        : plugin function resolves and round-trips a value
# =============================================================================

policytest {
  targets = ["feature_toplevel_plugin_block.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "abc" }
  meta  = { provider_type = "aws" }
}
