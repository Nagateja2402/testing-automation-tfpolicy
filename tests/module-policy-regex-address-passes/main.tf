# module-policy-regex-address-passes: module_policy core::regex_match(meta.address, ^module\.[a-z]+$) passes for module.q
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "q" {
  source = "./modules/q"
  name   = "module-policy-regex-address-passes-q"
  delay  = 1
}
