# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_toplevel_input_block
# Asserts        : input value drives the rule
# =============================================================================

policytest {
  targets = ["feature_toplevel_input_block.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "ok-name" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
