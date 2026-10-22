# operation-create-meta-operation-force-destroy-blocks: resource_policy meta.operation=="create" && force_destroy==true fails on force_destroy=false (message shows operation=create)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket                       = "operation-create-meta-operation-fo-q"
  force_destroy = false
}
