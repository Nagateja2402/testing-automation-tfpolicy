# basics-resource-policy-attrs-not-evaluated-at-init-passes: resource_policy using attrs in filter+enforce is not evaluated at init (no attrs-namespace error) and evaluates at plan
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-resource-policy-attrs-not-e-q" }
