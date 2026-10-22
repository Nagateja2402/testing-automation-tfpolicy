# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "a" {
  type    = string
  default = "x"
}

input "b" {
  type    = string
  default = "y"
}

resource_policy "aws_s3_bucket" "x" {
  enforce {
    condition     = core::try(attrs.tags.a, "") == input.a
    error_message = "x: tag a must be ${input.a}"
  }
}

resource_policy "aws_s3_bucket" "y" {
  enforce {
    condition     = core::try(attrs.tags.b, "") == input.b
    error_message = "y: tag b must be ${input.b}"
  }
}
