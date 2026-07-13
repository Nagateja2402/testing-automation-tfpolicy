# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_null_handling
# Asserts        : null surfaces vs present value
# =============================================================================

policytest {
  targets = ["feature_expr_null_handling.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x", versioning = { enabled = true } }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
