# provider-policy-try-missing-region-blocks: provider_policy core::try on provider without region: null attr -> Condition not met (no crash)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
}

resource "aws_s3_bucket" "q" { bucket = "provider-policy-try-missing-region-q" }
