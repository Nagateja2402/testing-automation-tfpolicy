# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_string
# Covers : input block with type string
# =============================================================================

input "sample_string" {
  type    = string
  default = "hello"
}

resource_policy "aws_s3_bucket" "feature_input_string" {
  enforce {
    condition    = input.sample_string != ""
    info_message = "input string resolved"
  }
}
