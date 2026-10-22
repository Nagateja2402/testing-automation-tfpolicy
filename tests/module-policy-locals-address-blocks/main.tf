# module-policy-locals-address-blocks: module_policy policy-level locals: meta.address != module.missing fails at init
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
  bucket_name       = "module-policy-locals-address-block-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
