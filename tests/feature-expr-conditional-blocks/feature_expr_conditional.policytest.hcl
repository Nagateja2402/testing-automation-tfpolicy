# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_conditional
# Asserts        : ternary picks the right branch
# =============================================================================

policytest {
  targets = ["feature_expr_conditional.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x", region = "us-east-1" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "x", region = "eu-west-1" }
  meta  = { provider_type = "aws" }
}
