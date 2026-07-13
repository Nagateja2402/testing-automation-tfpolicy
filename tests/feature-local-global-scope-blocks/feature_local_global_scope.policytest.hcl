# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_local_global_scope
# Asserts        : both rules in the file resolve the same file-scope local
# =============================================================================

policytest {
  targets = ["feature_local_global_scope.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "shared-x" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "nope" }
  meta  = { provider_type = "aws" }
}
