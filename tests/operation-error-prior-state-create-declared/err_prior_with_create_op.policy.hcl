# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "create_requires_environment_tag" {
  operations = ["create"]

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "New S3 buckets must have an Environment tag"
  }
}
