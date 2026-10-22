# provider-policy-default-tags-map-passes: provider_policy default_tags map must include Env=prod: passes
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
resource "aws_s3_bucket" "q" { bucket = "provider-policy-default-tags-map-p-q" }
