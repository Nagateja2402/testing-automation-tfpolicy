# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "p1" {
  locals {
    x = 1
  }
  enforce {
    condition     = local.x == 1
    error_message = "p1 x must be 1, was ${local.x}"
  }
}

resource_policy "aws_s3_bucket" "p2" {
  locals {
    x = 2
  }
  enforce {
    condition     = local.x == 2
    error_message = "p2 x must be 2, was ${local.x}"
  }
}
