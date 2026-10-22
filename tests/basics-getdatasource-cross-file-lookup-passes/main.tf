# basics-getdatasource-cross-file-lookup-passes: core::getdatasource("aws_region") lookup from a policy in another file resolves and passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
data "aws_region" "current" {}
resource "aws_s3_bucket" "q" { bucket = "basics-getdatasource-cross-file-lo-q" }
