# module-policy-meta-source-passes: module_policy meta.source==./modules/q passes (info_message shows source)
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
  name   = "module-policy-meta-source-passes-q"
}
