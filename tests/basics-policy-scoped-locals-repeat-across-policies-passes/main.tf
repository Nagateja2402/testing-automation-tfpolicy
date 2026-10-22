# basics-policy-scoped-locals-repeat-across-policies-passes: same policy-scoped local name (x) in two different policies is allowed; each uses its own value
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "basics-policy-scoped-locals-repeat-q" }
