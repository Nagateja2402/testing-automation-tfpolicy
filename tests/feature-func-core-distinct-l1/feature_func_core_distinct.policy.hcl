# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_distinct
# Covers : core::distinct removes duplicates
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_distinct" {
  enforce {
    condition    = core::length(core::distinct([1,1,2])) == 2
    info_message = "core::distinct executed"
  }
}
