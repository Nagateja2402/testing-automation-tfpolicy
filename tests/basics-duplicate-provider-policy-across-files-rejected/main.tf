# basics-duplicate-provider-policy-across-files-rejected: same provider_policy label defined in two files is a setup error (Duplicate provider policy block)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "basics-duplicate-provider-policy-a-q" }
