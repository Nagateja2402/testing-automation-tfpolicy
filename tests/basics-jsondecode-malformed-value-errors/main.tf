# basics-jsondecode-malformed-value-errors: resource_policy core::jsondecode on malformed JSON attribute surfaces a clear function-call error (not a crash)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_ssm_parameter" "p" {
  name  = "/basics-jsondecode-malformed-value/p"
  type  = "String"
  value = "{not valid json"
}
