# provider-policy-multiple-enforce-second-blocks: provider_policy two enforce blocks: second (region==eu-west-1) fails, message identifies enforce2
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-multiple-enforce-s-q" }
