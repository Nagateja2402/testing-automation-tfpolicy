# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "env" {
  type    = string
  default = "prod"
}

resource_policy "aws_s3_bucket" "uses_input" {
  enforce {
    condition     = core::try(attrs.tags.env, "") == input.env
    error_message = "input.env mismatch"
  }
}

resource_policy "aws_s3_bucket" "uses_var" {
  enforce {
    condition     = core::try(attrs.tags.env, "") == var.env
    error_message = "var.env mismatch"
  }
}
