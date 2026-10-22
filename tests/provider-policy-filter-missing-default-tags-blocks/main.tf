# provider-policy-filter-missing-default-tags-blocks: provider_policy filter matches us-east-1 provider; enforce (default_tags required) fails, other provider skipped by filter
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
resource "aws_s3_bucket" "q" { bucket = "provider-policy-filter-missing-def-q" }
