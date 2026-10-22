policytest {
  targets = ["basics_empty_and_null_tags_map.policy.hcl"]
}

resource "aws_s3_bucket" "empty_tags" {
  expect_failure = true
  attrs = {
    bucket = "basics-empty-and-null-tags-map-blo-empty"
    tags = {}
  }
}

resource "aws_s3_bucket" "null_tags" {
  expect_failure = true
  attrs = {
    bucket = "basics-empty-and-null-tags-map-blo-null"
    tags = null
  }
}

resource "aws_s3_bucket" "with_owner" {
  expect_failure = false
  attrs = {
    bucket = "basics-empty-and-null-tags-map-blo-ok"
    tags = { owner = "x" }
  }
}
