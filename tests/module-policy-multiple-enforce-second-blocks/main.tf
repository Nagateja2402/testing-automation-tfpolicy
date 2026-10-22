# module-policy-multiple-enforce-second-blocks: module_policy two enforce blocks: second (meta.source==./modules/other) fails, blocked at init
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "q" {
  source = "./modules/q"
  name   = "module-policy-multiple-enforce-sec-q"
}
