# provider-policy-unset-region-blocks: provider_policy attrs.region on provider without region: deferred at init, evaluated at plan with unset value and fails deterministically
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" {}
resource "aws_s3_bucket" "q" { bucket = "provider-policy-unset-region-block-q" }
