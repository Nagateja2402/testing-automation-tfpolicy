# PP-PROV-005: provider_policy targeting only "aws" — approved region passes
# Only the aws provider is subject to this policy. The provider is configured
# with us-east-1, which is on the approved list → passes.
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
  bucket        = "pp-prov-005-bucket-xyz"
  force_destroy = true
}
