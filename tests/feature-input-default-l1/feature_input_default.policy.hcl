# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_default
# Covers : input default used when value not provided
# =============================================================================

input "with_default" {
  type    = string
  default = "fallback"
}

resource_policy "aws_s3_bucket" "feature_input_default" {
  enforce {
    condition    = input.with_default == "fallback"
    info_message = "default value applied"
  }
}
