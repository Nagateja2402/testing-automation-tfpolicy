# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "create_needs_force_destroy" {
  enforce {
    condition     = meta.operation == "create" && attrs.force_destroy == true
    error_message = "on create, force_destroy must be true (operation=${meta.operation}, got ${attrs.force_destroy})"
  }
}
