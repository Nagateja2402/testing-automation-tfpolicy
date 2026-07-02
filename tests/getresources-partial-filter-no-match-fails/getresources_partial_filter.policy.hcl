# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_web_sg_in_vpc" {
  locals {
    matching_sgs = core::getresources("aws_security_group", {
      vpc_id = "vpc-static-001"
      name   = "web-sg"
    })
  }

  enforce {
    condition     = core::length(local.matching_sgs) > 0
    error_message = "No security group named 'web-sg' found in vpc-static-001"
  }
}
