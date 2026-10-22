# module-policy-input-source-mismatch-blocks: module_policy meta.source == input.expected_source (default ./modules/other) fails for module.s3_match
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
  bucket_name       = "module-policy-input-source-mismatc-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
module "s3_other" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-input-source-mismatc-s3-other"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
