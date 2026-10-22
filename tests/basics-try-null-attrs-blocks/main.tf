# basics-try-null-attrs-blocks: resource_policy core::try on null/nonexistent attrs fails gracefully with Condition not met (no crash)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {}
