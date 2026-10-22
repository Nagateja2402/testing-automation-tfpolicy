# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "name_tag_convention" {
  enforce {
    condition     = core::regex_match(attrs.tags["Name"], "^[A-Za-z0-9_.-]+$")
    error_message = "Name tag '${attrs.tags["Name"]}' violates naming convention ^[A-Za-z0-9_.-]+$"
  }
}
