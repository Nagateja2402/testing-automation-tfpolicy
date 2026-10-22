# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "environment" {
  type    = string
  default = "b"
}

resource_policy "aws_s3_bucket" "q" {
  enforce {
    condition = input.environment != ""
  }
}
