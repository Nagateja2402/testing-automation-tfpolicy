# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_test_cross_resource_reference (policy half)
# Covers : a policy whose rule reads attributes of a SIBLING resource. The
#          test framework exposes every test-file resource as
#          `<type>.<name>` in the eval context, so test fixtures can wire
#          one resource's attrs into another's policy evaluation.
# =============================================================================

# This rule asserts that for any aws_s3_bucket, there exists a sibling
# aws_s3_bucket_metadata_configuration resource pointing at the same bucket.
# It is a structural cross-resource reference: the policy itself doesn't read
# the bucket's attrs except to learn its name; everything else comes from
# core::getresources() lookups against the sibling type. Uses the real AWS
# provider resource `aws_s3_bucket_metadata_configuration` so the rule fires
# under both unit tests AND real `terraform plan`.
resource_policy "aws_s3_bucket" "feature_test_cross_resource_reference" {
  locals {
    bucket = core::try(attrs.bucket, "")

    # Look up every metadata_configuration declared in the plan/test file.
    metas = core::getresources("aws_s3_bucket_metadata_configuration", {})

    # The matching one points its `bucket` attribute at us.
    matching = [for m in local.metas : m if core::try(m.bucket, "") == local.bucket]
  }

  enforce {
    condition     = core::length(local.matching) > 0
    error_message = "bucket '${local.bucket}' must have a sibling aws_s3_bucket_metadata_configuration"
  }
}



resource_policy "aws_s3_bucket" "require_encryption_config_cross_check" {
  enforcement_level = "advisory"
  locals {
    configs = core::getresources("aws_s3_bucket_server_side_encryption_configuration", { bucket = attrs.bucket })
    has_config = core::length(local.configs) > 0
  }
  enforce {
    condition     = local.has_config
    error_message = "S3 bucket '${attrs.bucket}' must have an aws_s3_bucket_server_side_encryption_configuration attached"
  }
}