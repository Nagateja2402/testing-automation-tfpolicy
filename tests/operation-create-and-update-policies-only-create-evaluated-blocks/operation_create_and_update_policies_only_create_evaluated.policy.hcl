# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "create_fail" {
  operations = ["create"]
  enforce {
    condition     = false
    error_message = "CREATEPOLICY failing"
  }
}

resource_policy "aws_s3_bucket" "update_fail" {
  operations = ["update"]
  enforce {
    condition     = false
    error_message = "UPDATEPOLICY failing"
  }
}
