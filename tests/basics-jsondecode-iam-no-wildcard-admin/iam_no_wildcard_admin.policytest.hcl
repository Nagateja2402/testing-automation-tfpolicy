
policytest {
  targets = ["iam_no_wildcard_admin.policy.hcl"]
}

resource "aws_iam_policy" "scoped_policy_passes" {
  expect_failure = false
  attrs = {
    policy = "{\"Statement\":[{\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::my-bucket/*\"]}]}"
  }
}

resource "aws_iam_policy" "wildcard_admin_fails" {
  expect_failure = true
  attrs = {
    policy = "{\"Statement\":[{\"Action\":[\"*\"],\"Resource\":[\"*\"]}]}"
  }
}
