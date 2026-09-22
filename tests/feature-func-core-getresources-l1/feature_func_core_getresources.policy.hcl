# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_getresources
# Covers : core::getresources looks up sibling resources by type+filter
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_getresources" {
  enforce {
    condition    = core::length(core::getresources("aws_s3_bucket", { bucket = "lookup-me" })) >= 0
    info_message = "core::getresources executed"
  }
}
