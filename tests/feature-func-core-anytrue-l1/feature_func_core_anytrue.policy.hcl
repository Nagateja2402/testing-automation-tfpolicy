# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_anytrue
# Covers : core::anytrue returns true when at least one element is true
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_anytrue" {
  locals {
    checks = [
      core::try(attrs.tags.Environment, "") == "prod",
      core::try(attrs.tags.Environment, "") == "staging",
    ]
  }
  enforce {
    condition     = core::anytrue(local.checks)
    error_message = "Environment tag must be prod or staging"
  }
}
