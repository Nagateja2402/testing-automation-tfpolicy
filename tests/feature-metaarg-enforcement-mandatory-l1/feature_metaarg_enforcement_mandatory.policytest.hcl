# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_enforcement_mandatory
# Asserts        : mandatory failure fails the test
# =============================================================================

policytest {
  targets = ["feature_metaarg_enforcement_mandatory.policy.hcl"]
}


resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { acl = "private" }
  meta  = { provider_type = "aws" }
}
