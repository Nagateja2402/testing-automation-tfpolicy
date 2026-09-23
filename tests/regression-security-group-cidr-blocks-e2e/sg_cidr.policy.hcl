# Copyright (c) HashiCorp, Inc.
# GR-DEP/REG-BIN: locks in the real aws_security_group schema shape for
# ingress rules — `cidr_blocks` (list of string), not a scalar `cidr` —
# at the real Terraform plan/apply level.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_security_group" "no_public_ingress" {
  locals {
    public_rules = [
      for r in core::try(attrs.ingress, []) : r
      if core::contains(core::try(r.cidr_blocks, []), "0.0.0.0/0")
    ]
  }

  enforce {
    condition     = core::length(local.public_rules) == 0
    error_message = "security group must not allow ingress from 0.0.0.0/0"
  }
}
