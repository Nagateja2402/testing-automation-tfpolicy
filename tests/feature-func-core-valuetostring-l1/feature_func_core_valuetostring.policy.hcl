# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_valuetostring
# Covers : core::valuetostring renders unknown/null leaves as sentinels instead
#          of hard-failing with a JSON marshalling error. This is the primary
#          use-case: surfacing plan-time values (which often contain unknowns)
#          inside info_message or error_message for debugging.
# =============================================================================

resource_policy "aws_s3_bucket" "require_encryption_config_cross_check_valuetostring" {
  enforcement_level = "advisory"
  locals {
    configs = core::getresources("aws_s3_bucket_server_side_encryption_configuration", { bucket = attrs.bucket })
    has_config = core::length(local.configs) > 0
  }
  enforce {
    condition     = local.has_config
    error_message = "S3 bucket '${attrs.bucket}' must have an aws_s3_bucket_server_side_encryption_configuration attached"
    info_message = "Encryption Config: ${core::valuetostring(local.configs)}"
  }
}
