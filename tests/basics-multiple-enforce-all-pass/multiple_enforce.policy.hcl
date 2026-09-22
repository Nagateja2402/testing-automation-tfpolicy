# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "name_and_tag_required" {
  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "Bucket name must be specified"
  }

  enforce {
    condition     = core::try(attrs.tags.Owner, "") != ""
    error_message = "Bucket must have an Owner tag"
  }
}
