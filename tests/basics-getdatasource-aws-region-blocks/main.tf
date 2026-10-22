# basics-getdatasource-aws-region-blocks: resource_policy core::getdatasource("aws_region") region != required us-west-2 fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

data "aws_region" "current" {}
resource "aws_s3_bucket" "q" { bucket = "basics-getdatasource-aws-region-bl-q" }
