# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_unknown_handling
# Covers : unknown values propagate without flipping to deny
# =============================================================================

resource_policy "aws_s3_bucket" "feature_expr_unknown_handling" {
  enforcement_level = "advisory"
  enforce {
    condition     = core::try(attrs.bucket, "") == "literal-only"
    error_message = "literal mismatch (suppressed when unknown)"
  }
}
