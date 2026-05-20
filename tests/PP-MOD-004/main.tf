# PP-MOD-004: module_policy — module version meets minimum passes
# Uses terraform-aws-modules/vpc/aws pinned to ~> 5.0. Terraform resolves this
# to a 5.x version; meta.version will start with "5." → passes the minimum
# version check (must be >= 2.0, i.e. not starting with "0." or "1.").
# Apply is N/A — the plan is sufficient to verify the policy outcome.
# EXPECT_TFP_PLAN: PASS
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
  version = "~> 5.0"
}
