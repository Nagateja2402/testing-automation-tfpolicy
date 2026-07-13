# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_operations_update
# Covers : operations = [update] runs only on update with prior_attrs
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_operations_update" {
  operations = ["update"]
  enforce {
    condition    = core::try(attrs.bucket, "") == core::try(prior_attrs.bucket, "")
    error_message = "bucket name cannot change on update"
  }
}
