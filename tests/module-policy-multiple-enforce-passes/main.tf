# module-policy-multiple-enforce-passes: module_policy with two enforce blocks both passing
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
  name   = "module-policy-multiple-enforce-pas-q"
}
