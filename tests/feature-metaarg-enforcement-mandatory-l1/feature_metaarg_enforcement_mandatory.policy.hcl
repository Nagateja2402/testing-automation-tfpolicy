# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_enforcement_mandatory
# Covers : enforcement_level = mandatory produces hard failure
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_enforcement_mandatory" {
  enforcement_level = "mandatory"
  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "bucket name is mandatory"
  }
}
