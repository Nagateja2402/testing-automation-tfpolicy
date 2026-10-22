# operation-create-wildcard-s3-versioning-blocks: resource_policy "aws_s3_*" operations=[create] matches aws_s3_bucket; versioning disabled fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "b" {
  bucket = "operation-create-wildcard-s3-versi-bucket-nagateja"
  force_destroy = true
  versioning {
    enabled = false
  }
}
