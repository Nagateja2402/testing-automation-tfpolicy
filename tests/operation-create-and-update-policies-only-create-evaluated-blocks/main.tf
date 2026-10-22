# operation-create-and-update-policies-only-create-evaluated-blocks: create+update scoped failing policies on a create: only the create policy is evaluated; no-op skips both
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "operation-create-and-update-polici-q" }
