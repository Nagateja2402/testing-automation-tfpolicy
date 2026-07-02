# PP-PROV-001: provider_policy — approved region passes
# The aws provider is configured with us-east-1, which is on the approved list.
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
  bucket        = "pp-prov-001-bucket-xyz"
  force_destroy = true
}
