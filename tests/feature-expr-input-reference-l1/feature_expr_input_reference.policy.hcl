# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_input_reference
# Covers : input.<name> reads declared inputs
# =============================================================================

input "needle" {
  type    = string
  default = "needle"
}

resource_policy "aws_s3_bucket" "feature_expr_input_reference" {
  enforce {
    condition     = core::contains([input.needle], input.needle)
    error_message = "input round-trip failed"
  }
}
