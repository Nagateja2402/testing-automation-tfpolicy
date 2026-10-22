# provider-policy-locals-region-passes: provider_policy policy-level locals compare attrs.region to a file-level local: us-east-1 passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-locals-region-pass-q" }
