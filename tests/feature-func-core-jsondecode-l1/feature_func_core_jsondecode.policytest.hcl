# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_core_jsondecode
# Asserts        : core::jsondecode returns expected value
# =============================================================================

policytest {
  targets = ["feature_func_core_jsondecode.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
