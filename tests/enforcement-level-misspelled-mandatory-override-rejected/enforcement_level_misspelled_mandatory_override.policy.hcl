# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "mo" {
  enforcement_level = "mandatory_override"
  enforce {
    condition     = core::try(attrs.tags.Env, "") == "prod"
    error_message = "bucket must have Env tag set to prod"
  }
}
