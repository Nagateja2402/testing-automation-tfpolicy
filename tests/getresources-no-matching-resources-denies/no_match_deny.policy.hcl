# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "must_have_companion" {
  locals {
    companions = core::getresources("aws_s3_bucket", {
      bucket = "${attrs.bucket}-companion"
    })
  }

  enforce {
    condition     = core::length(local.companions) > 0
    error_message = "Each S3 bucket must have a companion bucket with '-companion' suffix"
  }
}
