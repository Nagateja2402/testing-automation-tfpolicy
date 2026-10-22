# module-policy-range-index-blocks: module_policy range index lookup: module.rogue not in allowed list fails at init
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "s3_match" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-range-index-blocks-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
module "rogue" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-range-index-blocks-rogue"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
