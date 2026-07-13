# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_enforce_error_message
# Asserts        : error_message surfaces in diagnostics
# =============================================================================

policytest {
  targets = ["feature_enforce_error_message.policy.hcl"]
}


resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { acl = "private" }
  meta  = { provider_type = "aws" }
}
