# provider-policy-default-tags-map-blocks: provider_policy default_tags map without Env=prod fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-default-tags-map-b-q" }
