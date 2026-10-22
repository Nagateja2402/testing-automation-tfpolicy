# basics-count-instances-all-compliant-passes: resource_policy evaluated across count=3 buckets, all compliant
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  count = 3
  bucket  = "basics-count-instances-all-complia-q${count.index}"
}
