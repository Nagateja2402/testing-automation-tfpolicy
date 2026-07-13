# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_enforce_single_block
# Asserts        : single enforce block evaluates
# =============================================================================

policytest {
  targets = ["feature_enforce_single_block.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
