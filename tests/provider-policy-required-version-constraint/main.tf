# PP-PROV-003: provider_policy — pinned provider version passes
# required_providers pins the aws provider to ~> 5.0; meta.version will be
# the resolved version string (e.g. "5.x.y"), which is non-empty → passes.
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
  bucket        = "pp-prov-003-bucket-xyz"
  force_destroy = true
}
