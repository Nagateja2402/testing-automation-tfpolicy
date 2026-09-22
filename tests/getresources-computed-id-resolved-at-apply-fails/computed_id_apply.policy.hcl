# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "must_have_logging_by_id" {
  locals {
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      id = attrs.id
    })
  }

  enforce {
    condition     = core::length(local.logging_configs) > 0
    error_message = "S3 bucket must have access logging configured"
  }
}
