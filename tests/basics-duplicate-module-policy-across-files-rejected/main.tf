# basics-duplicate-module-policy-across-files-rejected: same module_policy label defined in two files is a setup error (Duplicate module policy block)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
module "q" {
  source = "./modules/q"
  name   = "basics-duplicate-module-policy-acr-q"
}
