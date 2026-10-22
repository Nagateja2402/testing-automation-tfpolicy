# provider-policy-meta-type-passes: provider_policy meta.type=="aws" passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-meta-type-passes-q" }
