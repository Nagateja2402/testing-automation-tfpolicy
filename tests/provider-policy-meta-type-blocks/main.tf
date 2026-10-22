# provider-policy-meta-type-blocks: provider_policy meta.type=="google" fails at init for aws provider
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-meta-type-blocks-q" }
