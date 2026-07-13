# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_operations_create
# Asserts        : create-only rule runs on default (create) op
# =============================================================================

policytest {
  targets = ["feature_metaarg_operations_create.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
