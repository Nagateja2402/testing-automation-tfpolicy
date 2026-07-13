# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_enforcement_overridable
# Covers : mandatory_overridable level surfaces but can be bypassed
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_enforcement_overridable" {
  enforcement_level = "mandatory_overridable"
  enforce {
    condition     = false
    error_message = "overridable diagnostic"
  }
}
