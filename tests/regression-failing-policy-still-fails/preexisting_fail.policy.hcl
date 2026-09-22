# Copyright (c) HashiCorp, Inc.
# REG-BIN-002: Pre-existing failing policy must still fail on new binary.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "require_environment_tag" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "S3 bucket must have an Environment tag"
  }
}
