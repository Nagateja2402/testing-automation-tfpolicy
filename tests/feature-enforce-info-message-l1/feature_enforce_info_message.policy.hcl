# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_enforce_info_message
# Covers : info_message rendered regardless of outcome
# =============================================================================

resource_policy "aws_s3_bucket" "feature_enforce_info_message" {
  enforce {
    condition    = true
    info_message = "informational only: bucket=${core::try(attrs.bucket, "<none>")}"
  }
}
