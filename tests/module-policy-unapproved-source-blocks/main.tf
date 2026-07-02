# PP-MOD-002: module_policy — unapproved source is denied
# Uses a local module at ./modules/unapproved which is NOT on the approved list.
# EXPECT_TFP_PLAN: FAIL
# EXPECT_TFP_APPLY: FAIL

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

module "unapproved" {
  source = "./modules/unapproved"
}
