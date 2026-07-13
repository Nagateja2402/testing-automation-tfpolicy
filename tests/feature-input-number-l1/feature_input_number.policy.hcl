# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_number
# Covers : input block with type number
# =============================================================================

input "sample_number" {
  type    = number
  default = 3
}

resource_policy "aws_s3_bucket" "feature_input_number" {
  enforce {
    condition    = input.sample_number > 0
    info_message = "input number resolved"
  }
}
