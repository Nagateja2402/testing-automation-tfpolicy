# Copyright (c) HashiCorp, Inc.
# Mandatory enforcement (default): failure blocks the run.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "mandatory_versioning_check" {
  enforcement_level = "mandatory"

  enforce {
    condition     = core::try(attrs.versioning[0].enabled, false) == true
    error_message = "Mandatory: S3 buckets must have versioning enabled"
  }
}
