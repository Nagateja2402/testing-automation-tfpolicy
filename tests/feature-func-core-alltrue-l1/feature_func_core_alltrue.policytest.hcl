# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_core_alltrue
# Asserts        : core::alltrue is true only when every element is true
# =============================================================================

policytest {
  targets = ["feature_func_core_alltrue.policy.hcl"]
}

resource "aws_s3_bucket" "pass_all_true" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "prod"
    }
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_one_false" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
  meta = { provider_type = "aws" }
}
