# basics-meta-missing-field-try-default-passes: resource_policy filter meta.operation==create + core::try on missing meta.workspace_tag: no crash, falls back to default and passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-meta-missing-field-try-defa-q" }
