# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_input_map
# Asserts        : input of type map(string) resolves
# =============================================================================

policytest {
  targets = ["feature_input_map.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
