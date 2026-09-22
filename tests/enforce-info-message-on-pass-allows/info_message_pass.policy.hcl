# Copyright (c) HashiCorp, Inc.
# EC-ENF-002: info_message on passing condition.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "info_message_on_pass" {
  enforce {
    condition    = core::try(attrs.tags.Environment, "") != ""
    info_message = "Environment tag is present — compliant"
  }
}
