policytest {
  targets = ["basics_count_instances_all_compliant.policy.hcl"]
}

resource "aws_s3_bucket" "q0" {
  expect_failure = false
  attrs = {
    bucket = "basics-count-instances-all-complia-q0"
  }
}

resource "aws_s3_bucket" "q1" {
  expect_failure = false
  attrs = {
    bucket = "basics-count-instances-all-complia-q1"
  }
}

resource "aws_s3_bucket" "q2" {
  expect_failure = false
  attrs = {
    bucket = "basics-count-instances-all-complia-q2"
  }
}
