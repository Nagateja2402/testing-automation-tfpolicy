# provider-policy-try-region-passes: provider_policy core::try(attrs.region,"") == us-east-1 passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "q" { bucket = "provider-policy-try-region-passes-q" }
