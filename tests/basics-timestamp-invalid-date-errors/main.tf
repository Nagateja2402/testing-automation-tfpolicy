# basics-timestamp-invalid-date-errors: core::timecmp on a non-RFC3339 value surfaces Invalid function argument naming the bad value (not a crash)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_ssm_parameter" "p" {
  name  = "/basics-timestamp-invalid-date-erro/expiry"
  type  = "String"
  value = "not-a-date"
}
