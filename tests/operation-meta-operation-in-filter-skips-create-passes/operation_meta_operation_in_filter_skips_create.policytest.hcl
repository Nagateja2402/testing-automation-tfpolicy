policytest {
  targets = ["operation_meta_operation_in_filter_skips_create.policy.hcl"]
}

resource "aws_s3_bucket" "create_skipped" {
  expect_failure = false
  attrs = {
    bucket = "operation-meta-operation-in-filter-q"
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "update_skipped" {
  expect_failure = false
  attrs = {
    bucket = "operation-meta-operation-in-filter-q"
  }
  prior_attrs = {
    bucket = "operation-meta-operation-in-filter-q"
  }
  meta = {
    operation = "update"
  }
}
