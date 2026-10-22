# basics-ternary-conditional-attrs-blocks: resource_policy ternary (force_destroy ? object_lock_enabled==false : true): force_destroy with object lock fails, object lock without force_destroy passes
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket                       = "basics-ternary-conditional-attrs-b-q"
  force_destroy       = true
  object_lock_enabled = true
}
