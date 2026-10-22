# provider-policy-regex-region-blocks: provider_policy core::regex_match region regex fails for eu-west-1
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "eu-west-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-regex-region-block-q" }
