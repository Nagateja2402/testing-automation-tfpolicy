# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

locals {
  test_string = "hello"
}

resource_policy "aws_s3_bucket" "missing_local" {
  locals {
    greeting = "${local.test_string}-${local.undefined_local}"
  }
  enforce {
    condition     = local.greeting != ""
    error_message = "greeting must not be empty"
  }
}
