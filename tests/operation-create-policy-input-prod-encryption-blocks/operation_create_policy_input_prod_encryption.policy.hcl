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
  default = "prod"
}

resource_policy "aws_s3_bucket" "prod_needs_encryption" {
  operations = ["create"]
  enforce {
    condition     = input.environment != "prod" || core::try(attrs.tags["encryption"], "") == "kms"
    error_message = "INPUTCHK: env ${input.environment} requires encryption tag kms"
  }
}
