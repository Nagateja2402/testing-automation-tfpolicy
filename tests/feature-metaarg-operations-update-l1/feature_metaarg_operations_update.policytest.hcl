# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_operations_update
# Asserts        : rule fires on update operation with prior_attrs present
# =============================================================================

policytest {
  targets = ["feature_metaarg_operations_update.policy.hcl"]
}


resource "aws_s3_bucket" "update_fail" {
  expect_failure = true
  attrs       = { bucket = "new" }
  prior_attrs = { bucket = "old" }

  meta   = { provider_type = "aws", operation = "update" }
}
