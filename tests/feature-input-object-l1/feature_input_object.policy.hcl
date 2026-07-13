# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_object
# Covers : input block with type object({ a = number, b = string })
# =============================================================================

input "sample_object" {
  type    = object({ a = number, b = string })
  default = { a = 1, b = "x" }
}

resource_policy "aws_s3_bucket" "feature_input_object" {
  enforce {
    condition    = input.sample_object.a == 1
    info_message = "input object resolved"
  }
}
