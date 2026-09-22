# Copyright (c) HashiCorp, Inc.
# Advisory enforcement: failure produces a warning, does not block.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "advisory_versioning_check" {
  enforcement_level = "advisory"

  enforce {
    condition     = core::try(attrs.versioning[0].enabled, false) == true
    error_message = "Advisory: S3 buckets should have versioning enabled"
  }
}
