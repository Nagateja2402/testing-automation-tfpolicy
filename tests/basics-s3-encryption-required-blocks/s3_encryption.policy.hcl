# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "must_have_env_tag" {
  locals {
    env = core::try(attrs.tags.Environment, "")
  }

  enforce {
    condition     = local.env != ""
    error_message = "S3 bucket must have an Environment tag"
  }
}
