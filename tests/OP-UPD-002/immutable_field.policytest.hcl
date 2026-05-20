
policytest {
  targets = ["immutable_field.policy.hcl"]
}

resource "aws_s3_bucket" "update_same_bucket_name_passes" {
  expect_failure = false
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "prod"
    }
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
