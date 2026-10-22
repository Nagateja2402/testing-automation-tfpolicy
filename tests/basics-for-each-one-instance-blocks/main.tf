# basics-for-each-one-instance-blocks: resource_policy across for_each buckets: bad-bucket fails, others pass
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
locals { names = ["basics-for-each-one-instance-block-a", "bad-bucket", "basics-for-each-one-instance-block-c"] }
resource "aws_s3_bucket" "q" {
  for_each = toset(local.names)
  bucket     = each.value
}
