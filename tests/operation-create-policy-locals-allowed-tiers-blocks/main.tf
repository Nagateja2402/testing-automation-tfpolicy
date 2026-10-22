# operation-create-policy-locals-allowed-tiers-blocks: create-scoped resource_policy using policy-level locals (allowed tiers list): bronze denied with local-driven message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "operation-create-policy-locals-all-q"
  tags = { tier = "bronze" }
}
