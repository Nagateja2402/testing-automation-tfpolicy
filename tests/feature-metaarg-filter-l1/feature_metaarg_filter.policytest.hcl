# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_filter
# Asserts        : policy is skipped when filter evaluates false
# =============================================================================

policytest {
  targets = ["feature_metaarg_filter.policy.hcl"]
}


resource "aws_s3_bucket" "filtered_out" {
  expect_failure = false
  attrs = { acl = "private" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "filter_active_pass" {
  expect_failure = false
  attrs = { bucket = "okay" }
  meta  = { provider_type = "aws" }
}
