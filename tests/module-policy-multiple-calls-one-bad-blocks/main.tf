# module-policy-multiple-calls-one-bad-blocks: module_policy meta.address != module.q_bad: q_bad call fails at init, q_a/q_b pass
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "q_a" {
  source = "./modules/q"
  name   = "module-policy-multiple-calls-one-b-q-a"
  delay  = 1
}
module "q_b" {
  source = "./modules/q"
  name   = "module-policy-multiple-calls-one-b-q-b"
  delay  = 1
}
module "q_bad" {
  source = "./modules/q"
  name   = "module-policy-multiple-calls-one-b-q-bad"
  delay  = 1
}
