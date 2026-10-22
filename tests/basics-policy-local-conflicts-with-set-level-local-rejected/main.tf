# basics-policy-local-conflicts-with-set-level-local-rejected: policy-scoped local with same name as a set-level local is a setup error (Duplicate local expression)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "basics-policy-local-conflicts-with-q" }
