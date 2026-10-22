# basics-var-syntax-for-input-rejected: KNOWN ISSUE: var.<name> syntax for inputs is rejected (Unknown reference: root of a traversal must be one of input, local, attrs, meta, or prior_attrs); only input.<name> works
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "basics-var-syntax-for-input-reject-q"
  tags = { env = "prod" }
}
