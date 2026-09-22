# Copyright (c) HashiCorp, Inc.
# TF-E2E-001: Full lifecycle — create with policy pass.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_vpc" "must_have_environment_tag" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "VPC must have an Environment tag"
  }
}
