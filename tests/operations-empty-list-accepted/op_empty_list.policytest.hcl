# Note: operations=[] does not skip the policy; it evaluates like the default
# (create+update). This test verifies the policy passes when the tag is present.

policytest {
  targets = ["op_empty_list.policy.hcl"]
}

resource "aws_s3_bucket" "empty_operations_with_tag_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
