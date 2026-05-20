# PP-PROV-002: provider_policy — disallowed region is denied
# The aws provider is configured with ap-southeast-1, which is NOT on the approved list.
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
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "main" {
  bucket        = "pp-prov-002-bucket-xyz"
  force_destroy = true
}
