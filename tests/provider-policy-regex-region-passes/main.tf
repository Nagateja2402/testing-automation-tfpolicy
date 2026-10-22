# provider-policy-regex-region-passes: provider_policy core::regex_match(attrs.region, ^us-(east|west)-[0-9]$) passes for us-east-1
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-regex-region-passe-q" }
