# basics-required-input-without-value-rejected: required input without default/value is a setup error: Null input value (distinct from a policy failure)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-required-input-without-valu-q" }
