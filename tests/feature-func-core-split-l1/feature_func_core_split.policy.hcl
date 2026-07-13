# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_split
# Covers : core::split splits a string into a list
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_split" {
  enforce {
    condition    = core::length(core::split(",", "a,b,c")) == 3
    info_message = "core::split executed"
  }
}
