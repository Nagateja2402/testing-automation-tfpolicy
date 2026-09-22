# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_core_anytrue
# Asserts        : core::anytrue is true when at least one element is true
# =============================================================================

policytest {
  targets = ["feature_func_core_anytrue.policy.hcl"]
}

resource "aws_s3_bucket" "pass_one_true" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "staging"
    }
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_none_true" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
  meta = { provider_type = "aws" }
}
