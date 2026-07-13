# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_toplevel_input_block
# Covers : top-level input "name" {} declares a typed input with a default
# =============================================================================

input "min_length" {
  type    = number
  default = 3
}

resource_policy "aws_s3_bucket" "toplevel_input_block" {
  enforce {
    condition     = core::length(core::regexall("^.{${input.min_length},}$", core::try(attrs.bucket, ""))) > 0
    error_message = "bucket name shorter than ${input.min_length}"
  }
}
