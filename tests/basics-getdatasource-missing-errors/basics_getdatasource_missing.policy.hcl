# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "missing_ds" {
  locals {
    ds = core::getdatasource("aws_s3_bucket", { bucket = "basics-getdatasource-missing-error-does-not-exist" })
  }
  enforce {
    condition     = core::try(local.ds.arn, "") != ""
    error_message = "data source aws_s3_bucket basics-getdatasource-missing-error-does-not-exist returned no result"
  }
}
