# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_join
# Covers : core::join joins a list of strings
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_join" {
  enforce {
    condition    = core::join(",", ["a","b"]) == "a,b"
    info_message = "core::join executed"
  }
}
