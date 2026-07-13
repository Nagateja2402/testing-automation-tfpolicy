# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Asserts : a top-level `inputs {}` block inside a .policytest.hcl overrides
#           the policy's declared input defaults for the duration of the run.
#           Here we redirect `required_prefix` from "default-prefix-" to
#           "regression-", so a bucket named "regression-bucket" passes.
# =============================================================================

policytest {
  targets = ["feature_test_inputs_block.policy.hcl"]
}

inputs {
  required_prefix = "regression-"
}

resource "aws_s3_bucket" "pass_under_override" {
  expect_failure = false
  attrs = { bucket = "regression-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_old_default_value" {
  # Would have passed under the policy's "default-prefix-" default;
  # fails because the test inputs override pinned the prefix to "regression-".
  expect_failure = true
  attrs = { bucket = "default-prefix-bucket" }
  meta  = { provider_type = "aws" }
}
