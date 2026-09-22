# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_bool
# Covers : input block with type bool
# =============================================================================

input "sample_bool" {
  type    = bool
  default = true
}

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_input_bool" {
  enforce {
    condition    = input.sample_bool
    info_message = "input bool resolved"
  }
}
