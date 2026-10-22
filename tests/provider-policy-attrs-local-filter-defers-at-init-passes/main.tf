# provider-policy-attrs-local-filter-defers-at-init-passes: provider_policy attrs via policy local + filter: Unknown at init (deferred), passes at plan
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "provider-policy-attrs-local-filter-q" }
