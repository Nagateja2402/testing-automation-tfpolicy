# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_result_error
# Covers : error outcome via setup failure (e.g., missing required input)
# =============================================================================

input "must_be_set" {
  type    = string
  default = "fallback"
}

resource_policy "aws_s3_bucket" "feature_result_error" {
  enforce {
    condition     = input.must_be_set != ""
    error_message = "should never reach here without input"
  }
}
