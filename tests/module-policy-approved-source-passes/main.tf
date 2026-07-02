# PP-MOD-001: module_policy — approved source passes
# Uses a local module at ./modules/vpc which is on the approved sources list.
# EXPECT_TFP_PLAN: PASS
# EXPECT_TFP_APPLY: PASS

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
  source = "./modules/vpc"
}
