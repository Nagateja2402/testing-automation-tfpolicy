# module-policy-ternary-source-passes: module_policy ternary (address==module.q ? source==./modules/q : true) passes
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
  name   = "module-policy-ternary-source-passe-q"
  delay  = 1
}
