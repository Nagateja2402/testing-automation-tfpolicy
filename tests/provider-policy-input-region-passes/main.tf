# provider-policy-input-region-passes: provider_policy filter+enforce driven by input.region default us-east-1 passes
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
resource "aws_s3_bucket" "q" { bucket = "provider-policy-input-region-passe-q" }
