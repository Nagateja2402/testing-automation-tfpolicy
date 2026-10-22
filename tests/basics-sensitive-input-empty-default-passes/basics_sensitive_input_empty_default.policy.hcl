# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "secret" {
  type      = string
  default   = ""
  sensitive = true
}

resource_policy "aws_s3_bucket" "sens" {
  enforce {
    condition     = input.secret == "" && core::try(attrs.tags.Token, "") == ""
    error_message = "secret was ${input.secret}"
  }
}
