# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_prior_attrs
# Covers : prior_attrs reads the prior state on update/delete
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_expr_prior_attrs" {
  operations = ["update"]
  enforce {
    condition     = core::try(prior_attrs.bucket, "") != ""
    error_message = "prior_attrs.bucket should be set on update"
  }
}
