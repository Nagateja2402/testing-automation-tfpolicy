# basics-input-defined-in-other-file-passes: input defined in a.policy.hcl is accessible from a resource_policy in b.policy.hcl
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-input-defined-in-other-file-q" }
