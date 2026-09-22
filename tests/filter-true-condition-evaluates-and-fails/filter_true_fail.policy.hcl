# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "filter_skip_non_prod" {
  filter = core::try(attrs.tags.Environment, "") == "production"

  enforce {
    condition     = core::try(attrs.versioning[0].enabled, false) == true
    error_message = "Production S3 buckets must have versioning enabled"
  }
}
