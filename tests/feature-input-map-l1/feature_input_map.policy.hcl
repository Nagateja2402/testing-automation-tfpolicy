# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_map
# Covers : input block with type map(string)
# =============================================================================

input "sample_map" {
  type    = map(string)
  default = { k = "v" }
}

resource_policy "aws_s3_bucket" "feature_input_map" {
  enforce {
    condition    = core::contains(core::keys(input.sample_map), "k")
    info_message = "input map resolved"
  }
}
