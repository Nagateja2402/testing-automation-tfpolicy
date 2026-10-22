# enforce-two-create-policies-worst-result-blocks: two create policies on same resource: first passes, second fails -> deny (worst result wins)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "enforce-two-create-policies-worst-q" }
