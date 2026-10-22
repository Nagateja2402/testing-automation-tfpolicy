# module-policy-for-each-instances-passes: module_policy with module for_each (3 instances) all satisfy meta.source
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "q" {
  for_each = toset(["a", "b", "c"])
  source   = "./modules/q"
  name     = "module-policy-for-each-instances-p-${each.value}"
}
