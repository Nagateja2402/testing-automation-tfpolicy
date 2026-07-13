# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_null_handling
# Covers : null values handled via core::try
# =============================================================================

resource_policy "aws_s3_bucket" "feature_expr_null_handling" {
  enforce {
    condition     = core::try(attrs.versioning, null) != null
    error_message = "versioning attribute missing"
  }
}
