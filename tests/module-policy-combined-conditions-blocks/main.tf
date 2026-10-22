# module-policy-combined-conditions-blocks: module_policy 3 combined conditions: module bad_name violates address regex ^module\.s3_ (blocked at init)
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
  bucket_name       = "module-policy-combined-conditions-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
module "bad_name" {
  source            = "./modules/s3"
  bucket_name       = "module-policy-combined-conditions-bad-name"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
