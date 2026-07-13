# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Asserts : input values resolve correctly when supplied via a sibling
#           .policyvars.hcl file passed through `tfpolicy test --input-file`.
#
# Run:
#   tfpolicy test \
#     --policies ./policies \
#     --tests    ./policies \
#     --input-file ./policies/feature_test_input_varfile.policyvars.hcl
# =============================================================================

policytest {
  targets = ["feature_test_input_varfile.policy.hcl"]
}

# Pass: region not in the blocked list supplied by the varfile.
resource "aws_s3_bucket" "pass_allowed_region" {
  expect_failure = false
  attrs = { bucket = "ok-bucket", region = "us-east-1" }
  meta  = { provider_type = "aws" }
}

# Fail: the varfile blocks 'ap-southeast-1'.
resource "aws_s3_bucket" "fail_blocked_region" {
  expect_failure = true
  attrs = { bucket = "blocked-bucket", region = "ap-southeast-1" }
  meta  = { provider_type = "aws" }
}
