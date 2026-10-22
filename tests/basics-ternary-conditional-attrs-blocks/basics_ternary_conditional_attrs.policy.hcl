# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "ternary" {
  enforce {
    condition     = attrs.force_destroy ? attrs.object_lock_enabled == false : true
    error_message = "buckets with force_destroy enabled must not enable object lock"
  }
}
