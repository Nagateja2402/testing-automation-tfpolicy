# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_instance" "no_t2_micro" {
  enforce {
    condition     = core::try(attrs.instance_type, "") != "t2.micro"
    error_message = "Instance type t2.micro is not allowed"
  }
}
