# module-policy-meta-address-blocks: module_policy meta.address mismatch (module.s3q vs module.expected_other) fails at init; message names address and source
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

module "s3q" { source = "./modules/s3" }
