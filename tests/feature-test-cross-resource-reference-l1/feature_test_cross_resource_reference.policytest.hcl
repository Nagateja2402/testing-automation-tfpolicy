# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Asserts : `core::getresources` resolves to OTHER resources declared in the
#           same .policytest.hcl, enabling cross-resource references during
#           tests without needing a real Terraform plan.
# =============================================================================

policytest {
  targets = ["feature_test_cross_resource_reference.policy.hcl"]
}

# =============================================================================
# Reference targets — visible to getresources() but `skip = true` so they
# aren't evaluated as test cases. The pass bucket "regression-data" has BOTH
# siblings (metadata + sse). The fail bucket "orphan-bucket" has neither,
# tripping both cross-reference rules.
# =============================================================================

resource "aws_s3_bucket_metadata_configuration" "for_regression_bucket" {
  skip = true
  attrs = {
    bucket = "regression-data"
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "for_regression_bucket" {
  skip = true
  attrs = {
    bucket = "regression-data"
  }
  meta = { provider_type = "aws" }
}

# Pass: both sibling resources exist and point at this bucket.
resource "aws_s3_bucket" "pass_has_both_siblings" {
  expect_failure = false
  attrs = { bucket = "regression-data" }
  meta  = { provider_type = "aws" }
}

# Fail: no sibling resources for this bucket. Both cross-resource rules
# (metadata + sse) deny, so the test case fails.
resource "aws_s3_bucket" "fail_no_siblings" {
  expect_failure = true
  attrs = { bucket = "orphan-bucket" }
  meta  = { provider_type = "aws" }
}
