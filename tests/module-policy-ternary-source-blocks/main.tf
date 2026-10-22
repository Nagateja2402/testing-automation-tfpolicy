# module-policy-ternary-source-blocks: module_policy ternary (address==module.q ? source==./modules/other : true) fails at init
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
  name   = "module-policy-ternary-source-block-q"
  delay  = 1
}
