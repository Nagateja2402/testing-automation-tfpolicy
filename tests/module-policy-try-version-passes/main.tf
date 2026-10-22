# module-policy-try-version-passes: module_policy core::try(semverconstraint(meta.version,">= 1.0.0"),false) passes for registry module v1.0.2
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "dirmod" {
  source   = "hashicorp/dir/template"
  version  = "1.0.2"
  base_dir = "${path.module}/templates"
}
