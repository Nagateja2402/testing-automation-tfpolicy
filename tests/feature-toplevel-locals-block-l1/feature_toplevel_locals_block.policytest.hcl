# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_toplevel_locals_block
# Asserts        : file-scope locals resolve in resource_policy bodies
# =============================================================================

policytest {
  targets = ["feature_toplevel_locals_block.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "prod-data" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "data" }
  meta  = { provider_type = "aws" }
}
