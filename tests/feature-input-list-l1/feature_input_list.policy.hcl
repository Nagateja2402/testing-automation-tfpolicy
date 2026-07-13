# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_list
# Covers : input block with type list(string)
# =============================================================================

input "sample_list" {
  type    = list(string)
  default = ["a","b"]
}

resource_policy "aws_s3_bucket" "feature_input_list" {
  enforce {
    condition    = core::length(input.sample_list) == 2
    info_message = "input list resolved"
  }
}
