# basics-init-safe-provider-and-plan-attrs-resource-passes: init-safe provider_policy (meta/input/locals) passes; resource_policy attrs evaluated only at plan and passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "basics-init-safe-provider-and-plan-q" }
