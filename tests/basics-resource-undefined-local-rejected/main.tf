# basics-resource-undefined-local-rejected: resource_policy referencing an undefined local is a setup error naming the local (Undefined Reference)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "basics-resource-undefined-local-re-q" }
