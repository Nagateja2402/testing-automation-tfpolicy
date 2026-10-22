policytest {
  targets = ["basics_ternary_conditional_attrs.policy.hcl"]
}

resource "aws_s3_bucket" "force_destroy_with_object_lock" {
  expect_failure = true
  attrs = {
    bucket = "basics-ternary-conditional-attrs-b-q"
    force_destroy = true
    object_lock_enabled = true
  }
}

resource "aws_s3_bucket" "no_force_destroy_with_object_lock" {
  expect_failure = false
  attrs = {
    bucket = "basics-ternary-conditional-attrs-b-q2"
    force_destroy = false
    object_lock_enabled = true
  }
}
