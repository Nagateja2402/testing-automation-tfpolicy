# module-policy-attrs-map-missing-key-defers-unknown: KNOWN ISSUE: module_policy attrs.tags missing owner key should fail but stays Unknown (deferred) at init/plan/apply; currently-true expectation is plan UNKNOWN
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
  name   = "module-policy-attrs-map-missing-ke-q"
  tags   = { env = "dev" }
}
