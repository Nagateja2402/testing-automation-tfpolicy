# PP-MOD-003: module_policy — module version below minimum is denied
# Uses terraform-aws-modules/vpc/aws pinned to ~> 1.0. Terraform resolves this
# to a 1.x version; meta.version will start with "1." → fails the minimum
# version check (must be >= 2.0).
# EXPECT_TFP_PLAN: FAIL
# EXPECT_TFP_APPLY: N/A

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.0"
}
