# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_enforce_multiple_blocks
# Covers : multiple enforce blocks all evaluated
# =============================================================================

resource_policy "aws_s3_bucket" "feature_enforce_multiple_blocks" {
  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "bucket required"
  }
  enforce {
    condition     = core::length(core::regexall("^.{0,63}$", core::try(attrs.bucket, ""))) > 0
    error_message = "bucket too long"
  }
}
