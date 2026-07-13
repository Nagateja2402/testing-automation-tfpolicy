# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_sensitive
# Covers : input marked sensitive masks value in diagnostics
# =============================================================================

input "secret" {
  type      = string
  default   = "shhh"
  sensitive = true
}

resource_policy "aws_s3_bucket" "feature_input_sensitive" {
  enforce {
    condition    = input.secret != ""
    info_message = "sensitive input length checked"
  }
}
