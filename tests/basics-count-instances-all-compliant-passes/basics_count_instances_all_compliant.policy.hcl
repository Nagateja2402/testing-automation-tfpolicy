# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "multi_instance" {
  enforce {
    condition     = core::length(core::regexall("^basics-count-instances-all-complia-", attrs.bucket)) > 0
    error_message = "bucket name must start with basics-count-instances-all-complia-"
  }
}
