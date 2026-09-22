policytest {
  targets = ["create_delete_combo.policy.hcl"]
}

resource "aws_s3_bucket" "any_resource" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
  meta = { provider_type = "aws" }
}
