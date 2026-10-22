# provider-policy-ternary-default-tags-blocks: provider_policy ternary: us-east-1 provider without default_tags fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-ternary-default-ta-q" }
