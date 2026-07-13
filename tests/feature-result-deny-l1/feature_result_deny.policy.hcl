# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_result_deny
# Covers : false condition produces Deny
# =============================================================================

resource_policy "aws_s3_bucket" "feature_result_deny" {
  enforcement_level = "advisory"
  enforce {
    condition     = false
    error_message = "deny outcome"
  }
}
