# basics-resource-locals-cloudtrail-blocks: resource_policy file-level + policy-level locals; cloudtrail without log file validation fails with local-derived message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_cloudtrail" "t" {
  name                          = "basics-resource-locals-cloudtrail-trail"
  s3_bucket_name                = "basics-resource-locals-cloudtrail-trail-bucket-nagateja"
  enable_log_file_validation    = false
}
