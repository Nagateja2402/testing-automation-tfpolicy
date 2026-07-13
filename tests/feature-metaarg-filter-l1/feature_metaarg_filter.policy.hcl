# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_filter
# Covers : filter attribute skips evaluation when false
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_filter" {
  filter = core::try(attrs.bucket, "") != ""
  enforce {
    condition     = core::length(core::regexall("^.{3,}$", attrs.bucket)) > 0
    error_message = "bucket too short"
  }
}
