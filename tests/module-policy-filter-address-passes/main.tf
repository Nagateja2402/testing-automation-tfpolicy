# module-policy-filter-address-passes: module_policy filter meta.address==module.s3_match; enforce meta.source passes (meta-based)
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
  bucket_name       = "module-policy-filter-address-passe-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
module "s3_other" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-filter-address-passe-s3-other"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
