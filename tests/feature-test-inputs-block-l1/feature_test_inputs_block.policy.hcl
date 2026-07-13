# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_test_inputs_block (policy half)
# Covers : a policy that declares an `input` with a default value, intended to
#          be overridden from the `.policytest.hcl` `inputs {}` block.
# =============================================================================

input "required_prefix" {
  type    = string
  default = "default-prefix-"  # intentionally NOT the value the test asserts
}

resource_policy "aws_s3_bucket" "feature_test_inputs_block" {
  enforcement_level = "advisory"
  enforce {
    condition     = core::length(core::regexall("^${input.required_prefix}", core::try(attrs.bucket, ""))) > 0
    error_message = "bucket must start with '${input.required_prefix}'"
  }
}
