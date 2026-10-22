policytest {
  targets = ["basics_unique_names_within_single_file.policy.hcl"]
}

resource "aws_s3_bucket" "b" {
  expect_failure = false
  attrs = {
    bucket = "basics-unique-names-within-single-b-nagateja"
    tags = { a = "x", b = "y" }
  }
}

resource "aws_s3_bucket" "missing_tag_b" {
  expect_failure = true
  attrs = {
    bucket = "basics-unique-names-within-single-b2-nagateja"
    tags = { a = "x" }
  }
}
