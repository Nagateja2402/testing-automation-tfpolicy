# Copyright (c) HashiCorp, Inc.
# REG-BIN-001: Pre-existing passing policy must still pass on new binary.
# Uses a simple resource_policy that has always passed.

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
