# basics-timestamp-past-expiry-blocks: resource_policy core::timecmp(attrs.value, core::timestamp())>0 fails for a 2020 expiry
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_ssm_parameter" "p" {
  name  = "/basics-timestamp-past-expiry-block/expiry"
  type  = "String"
  value = "2020-01-01T00:00:00Z"
}
