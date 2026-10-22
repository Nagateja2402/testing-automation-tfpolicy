# module-policy-regex-address-blocks: module_policy core::regex_match(meta.address, ^module\.[a-z]+$) fails for module.Bad_Name at init
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "Bad_Name" {
  source = "./modules/q"
  name   = "module-policy-regex-address-blocks-bad-name"
  delay  = 1
}
