# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_operations_delete
# Asserts        : delete-only rule runs on delete operation
# =============================================================================

policytest {
  targets = ["feature_metaarg_operations_delete.policy.hcl"]
}


resource "aws_s3_bucket" "delete_pass" {
  expect_failure = false
  prior_attrs = { bucket = "old" }

  meta   = { provider_type = "aws", operation = "delete" }
}
