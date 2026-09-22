# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_iam_policy" "no_full_admin_privileges" {
  locals {
    policy_doc = core::jsondecode(attrs.policy)

    actions_with_wildcard = core::length([
      for statement in local.policy_doc.Statement : statement
      if core::length([for action in statement.Action : action if action == "*"]) > 0
    ]) > 0

    resource_with_wildcard = core::length([
      for statement in local.policy_doc.Statement : statement
      if core::length([for resource in statement.Resource : resource if resource == "*"]) > 0
    ]) > 0
  }

  enforce {
    condition     = local.actions_with_wildcard ? !local.resource_with_wildcard : true
    error_message = "IAM policies should not allow full administrative privileges (Action=* on Resource=*)."
  }
}
