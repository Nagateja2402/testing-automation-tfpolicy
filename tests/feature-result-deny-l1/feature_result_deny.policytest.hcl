# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_result_deny
# Asserts        : false condition fails the test
# =============================================================================

policytest {
  targets = ["feature_result_deny.policy.hcl"]
}


resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
