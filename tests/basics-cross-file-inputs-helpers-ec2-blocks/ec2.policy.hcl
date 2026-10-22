# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_instance" "tagged" {
  enforce {
    condition     = core::try(attrs.tags[local.required_tag_key], "") == input.required_env
    error_message = "ec2 instance needs tag ${local.required_tag_key}=${input.required_env}"
  }
}
