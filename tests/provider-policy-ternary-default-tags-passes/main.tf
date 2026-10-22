# provider-policy-ternary-default-tags-passes: provider_policy ternary (region us-east-1 ? default_tags Env==prod : true) passes with Env=prod
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { Env = "prod" }
  }
}
resource "aws_s3_bucket" "q" { bucket = "provider-policy-ternary-default-ta-q" }
