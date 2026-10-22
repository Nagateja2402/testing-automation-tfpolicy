# provider-policy-filter-region-passes: provider_policy filter attrs.region==us-east-1 evaluates only the matching provider (2 providers), enforce passes
# tfp plan: PASS
# tfp apply: PASS
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
resource "aws_s3_bucket" "q" { bucket = "provider-policy-filter-region-pass-q" }
