# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_enforce_error_message
# Covers : error_message rendered on failed condition
# =============================================================================

resource_policy "aws_s3_bucket" "feature_enforce_error_message" {
  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "bucket attribute is required, found empty value"
  }
}
