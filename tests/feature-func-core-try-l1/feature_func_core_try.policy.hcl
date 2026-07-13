# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_try
# Covers : core::try returns fallback when expression errors
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_try" {
  enforce {
    condition    = core::try(attrs.missing, "fallback") == "fallback"
    info_message = "core::try executed"
  }
}
