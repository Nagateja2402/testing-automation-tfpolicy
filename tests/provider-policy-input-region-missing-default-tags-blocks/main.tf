# provider-policy-input-region-missing-default-tags-blocks: provider_policy input.region filter matches, enforce (default_tags required) fails with input in message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
resource "aws_s3_bucket" "q" { bucket = "provider-policy-input-region-missi-q" }
