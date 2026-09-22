# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_state_prior_attrs_on_update
# Covers : prior_attrs populated on update
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_state_prior_attrs_on_update" {
  operations = ["update"]
  enforce {
    condition     = core::try(prior_attrs.bucket, "") == "old"
    error_message = "expected prior bucket = old"
  }
}
