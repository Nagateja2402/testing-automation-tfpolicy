# provider-policy-range-index-blocks: provider_policy range index lookup: eu-west-1 not in allowed list (idx -1) fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "eu-west-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-range-index-blocks-q" }
