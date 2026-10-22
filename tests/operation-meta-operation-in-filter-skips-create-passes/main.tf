# operation-meta-operation-in-filter-skips-create-passes: filter meta.operation=="delete" is false on create/update: policy skipped, no enforce diagnostics
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "operation-meta-operation-in-filter-q" }
