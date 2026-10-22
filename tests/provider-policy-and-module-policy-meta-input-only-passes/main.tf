# provider-policy-and-module-policy-meta-input-only-passes: provider_policy and module_policy using only meta/input pass at init and plan, no attrs diagnostic
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
  name   = "provider-policy-and-module-policy-q"
}
