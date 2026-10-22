# operation-meta-operation-in-enforce-create-passes: enforce condition meta.operation=="create": passes on create, fails on update
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "operation-meta-operation-in-enforc-q" }
