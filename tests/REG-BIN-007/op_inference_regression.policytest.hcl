
policytest {
  targets = ["op_inference_regression.policy.hcl"]
}

# attrs-only → inferred create → policy evaluates → passes with tag
resource "aws_s3_bucket" "inferred_create_with_tag_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}

# explicit update → create-only policy skipped → passes
resource "aws_s3_bucket" "explicit_update_skips_create_policy" {
  expect_failure = false
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
  prior_attrs = {
    bucket = "my-bucket"
  }
}
