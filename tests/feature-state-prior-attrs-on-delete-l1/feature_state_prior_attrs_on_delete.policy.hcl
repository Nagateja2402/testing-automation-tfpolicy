# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_state_prior_attrs_on_delete
# Covers : prior_attrs populated on delete
# =============================================================================

resource_policy "aws_s3_bucket" "feature_state_prior_attrs_on_delete" {
  operations = ["delete"]
  enforce {
    condition     = core::try(prior_attrs.bucket, "") != ""
    error_message = "prior bucket missing on delete"
  }
}
