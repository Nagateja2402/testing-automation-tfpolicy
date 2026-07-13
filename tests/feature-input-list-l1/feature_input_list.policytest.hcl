# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_input_list
# Asserts        : input of type list(string) resolves
# =============================================================================

policytest {
  targets = ["feature_input_list.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
