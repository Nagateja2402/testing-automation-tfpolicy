# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_result_unknown
# Covers : unknown value in condition produces Unknown
# =============================================================================

resource_policy "aws_s3_bucket" "feature_result_unknown" {
  enforcement_level = "advisory"
  enforce {
    condition     = core::try(attrs.maybe_unknown, null) == "value"
    error_message = "unknown outcome (suppressed)"
  }
}
