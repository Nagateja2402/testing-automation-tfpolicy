# module-policy-attrs-map-defers-unknown: KNOWN ISSUE: module_policy referencing attrs.tags stays Unknown (deferred) at init/plan/apply instead of evaluating with module inputs; currently-true expectation is plan UNKNOWN
# tfp plan: UNKNOWN
# tfp apply: UNKNOWN
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "q" {
  source = "./modules/q"
  name   = "module-policy-attrs-map-defers-unk-q"
  tags   = { owner = "platform", env = "dev" }
}
