# module-policy-range-index-passes: module_policy range index lookup of meta.address in allowed list passes
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
module "s3_match" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-range-index-passes-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
module "s3_other" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-range-index-passes-s3-other"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
