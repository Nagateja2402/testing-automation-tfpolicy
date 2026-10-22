# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "first_pass" {
  operations = ["create"]
  enforce {
    condition     = true
    error_message = "FIRSTPASS should not show"
  }
}

resource_policy "aws_s3_bucket" "second_fail" {
  operations = ["create"]
  enforce {
    condition     = false
    error_message = "SECONDFAIL failing"
  }
}
