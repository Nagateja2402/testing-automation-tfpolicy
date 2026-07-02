# PP-PROV-004: provider_policy using attrs — passes when region is us-east-1
# The policy checks core::try(attrs.region, "") == "us-east-1". With the
# provider configured to us-east-1 this condition is true → passes.
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

resource "aws_s3_bucket" "main" {
  bucket        = "pp-prov-004-bucket-xyz"
  force_destroy = true
}
