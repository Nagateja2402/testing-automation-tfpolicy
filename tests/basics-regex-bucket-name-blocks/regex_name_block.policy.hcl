# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "bucket_name_must_start_with_prefix" {
  locals {
    bucket_name    = core::try(attrs.bucket, "")
    prefix_pattern = "^(data|logs|backup|archive)-"
  }

  enforce {
    condition     = local.bucket_name != "" && core::length(core::regexall(local.prefix_pattern, local.bucket_name)) > 0
    error_message = "S3 bucket name '${local.bucket_name}' must start with data-, logs-, backup-, or archive-"
  }
}
