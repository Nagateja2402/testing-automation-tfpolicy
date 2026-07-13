# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_enforce_multiple_blocks
# Asserts        : first enforce fails on empty, second fails on overlong
# =============================================================================

policytest {
  targets = ["feature_enforce_multiple_blocks.policy.hcl"]
}


resource "aws_s3_bucket" "empty_fail" {
  expect_failure = true
  attrs = { acl = "private" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "ok_pass" {
  expect_failure = false
  attrs = { bucket = "ok" }
  meta  = { provider_type = "aws" }
}
