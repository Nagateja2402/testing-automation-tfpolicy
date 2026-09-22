# Copyright (c) HashiCorp, Inc.
# REG-BIN-003: Output format unchanged across binary versions.
# Uses a known-pass policy; validates exit code is 0 and output contains expected text.

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
