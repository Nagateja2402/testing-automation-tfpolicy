# operation-create-policy-input-prod-encryption-blocks: create-scoped resource_policy driven by input.environment=prod: tags.encryption=none denied
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket                    = "operation-create-policy-input-prod-q"
  tags = { encryption = "none" }
}
