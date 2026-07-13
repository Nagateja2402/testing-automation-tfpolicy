# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_enforcement_advisory
# Covers : enforcement_level = advisory reports warning, not error
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_enforcement_advisory" {
  enforcement_level = "advisory"
  enforce {
    condition     = false
    error_message = "advisory diagnostic"
  }
}
