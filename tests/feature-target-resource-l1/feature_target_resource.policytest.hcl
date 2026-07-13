# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_target_resource
# Asserts        : resource block is evaluated
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "any" }
  meta  = { provider_type = "aws" }
}
