# enforcement-level-misspelled-mandatory-override-rejected: KNOWN ISSUE: misspelled enforcement_level "mandatory_override" is not rejected at init/policy-set setup; it only errors per resource at plan (Invalid enforcement level, allowed values listed)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "enforcement-level-misspelled-manda-q"
  tags = { Env = "prod" }
}
