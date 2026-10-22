# provider-policy-locals-region-blocks: provider_policy policy-level locals: provider region us-west-2 != allowed us-east-1 fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-west-2" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-locals-region-bloc-q" }
