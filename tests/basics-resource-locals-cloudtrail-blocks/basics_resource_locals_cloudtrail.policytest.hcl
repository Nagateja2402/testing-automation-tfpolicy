policytest {
  targets = ["basics_resource_locals_cloudtrail.policy.hcl"]
}

resource "aws_cloudtrail" "no_validation" {
  expect_failure = true
  attrs = {
    name = "basics-resource-locals-cloudtrail-trail"
    s3_bucket_name = "basics-resource-locals-cloudtrail-trail-bucket-nagateja"
    enable_log_file_validation = false
  }
}

resource "aws_cloudtrail" "with_validation" {
  expect_failure = false
  attrs = {
    name = "basics-resource-locals-cloudtrail-trail"
    s3_bucket_name = "basics-resource-locals-cloudtrail-trail-bucket-nagateja"
    enable_log_file_validation = true
  }
}
