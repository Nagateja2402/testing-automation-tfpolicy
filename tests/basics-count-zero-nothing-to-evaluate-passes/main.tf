# basics-count-zero-nothing-to-evaluate-passes: resource_policy with count=0 resource: nothing to evaluate, clean pass (planned_and_finished)
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  count         = 0
  bucket          = "basics-count-zero-nothing-to-evalu-${count.index}"
  force_destroy = true
}
