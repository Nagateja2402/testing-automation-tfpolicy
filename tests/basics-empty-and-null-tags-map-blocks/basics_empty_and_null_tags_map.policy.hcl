# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "tags_has_owner" {
  enforce {
    condition     = core::try(attrs.tags["owner"], null) != null
    error_message = "bucket tags must contain an owner key (tags empty or null)"
  }
}
