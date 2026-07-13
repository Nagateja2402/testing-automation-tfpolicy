# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_input_number
# Asserts        : input of type number resolves
# =============================================================================

policytest {
  targets = ["feature_input_number.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
