# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "bad_case" {
  operations = ["Create"]
  enforce {
    condition     = true
    error_message = "x"
  }
}
