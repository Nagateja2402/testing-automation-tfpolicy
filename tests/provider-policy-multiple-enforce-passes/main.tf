# provider-policy-multiple-enforce-passes: provider_policy with two enforce blocks (meta.type, attrs.region) both passing
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-multiple-enforce-p-q" }
