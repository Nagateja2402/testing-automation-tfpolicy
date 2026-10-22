# e2e-ternary-unknown-at-plan-resolves-pass-at-apply: ternary driven by terraform_data.x.id (unknown at plan): UNKNOWN at plan, resolves to pass at apply (terraform_data only, no AWS resources); L1 N/A: tfpolicy 0.4.0 cannot acquire a schema for the builtin terraform provider
# tfp plan: UNKNOWN
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "terraform_data" "x" {
  input = "seed"
}
resource "terraform_data" "y" {
  input = {
    Check = "yes"
    Mode  = terraform_data.x.id
    Delay = "5"
  }
}
