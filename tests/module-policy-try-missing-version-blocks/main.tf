# module-policy-try-missing-version-blocks: module_policy core::try(semverconstraint(meta.version,...),false): local module has no version -> default false fails
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
  bucket_name       = "module-policy-try-missing-version-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
