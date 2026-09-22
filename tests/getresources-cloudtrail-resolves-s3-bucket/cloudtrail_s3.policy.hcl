# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_cloudtrail" "ensure_private_s3_bucket" {
  locals {
    matching_buckets = core::getresources("aws_s3_bucket", {
      bucket = attrs.s3_bucket_name
    })
    # In AWS provider v5, acl is managed by the standalone aws_s3_bucket_acl resource.
    # Look up the ACL resource using the same bucket name.
    matching_acls = core::getresources("aws_s3_bucket_acl", {
      bucket = attrs.s3_bucket_name
    })
    acl = core::length(local.matching_acls) > 0 ? core::try(local.matching_acls[0].acl, "") : ""
  }

  enforce {
    condition     = core::length(local.matching_buckets) > 0
    error_message = "CloudTrail must reference an S3 bucket that exists in this configuration"
  }

  enforce {
    condition     = local.acl == "private"
    error_message = "CloudTrail S3 bucket must have acl set to private"
  }
}
