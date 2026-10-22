# provider-policy-range-index-passes: provider_policy locals use core::range + for-expression index lookup; us-east-1 index>=0 passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-range-index-passes-q" }
