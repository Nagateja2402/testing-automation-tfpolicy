# module-policy-locals-address-passes: module_policy policy-level locals (prefix + expected) meta.address==local.expected passes
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
  bucket_name       = "module-policy-locals-address-passe-s3-match"
  enable_versioning = true
  sse_algorithm     = "AES256"
}
