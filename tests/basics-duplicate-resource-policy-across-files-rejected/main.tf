# basics-duplicate-resource-policy-across-files-rejected: same resource_policy label defined in two files is a setup error (Duplicate resource policy block)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-duplicate-resource-policy-a-q" }
resource "aws_s3_bucket" "b" { bucket = "basics-duplicate-resource-policy-a-bucket-nagateja" }
