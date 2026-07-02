
policytest {
  targets = ["infer_override.policy.hcl"]
}

# Both attrs and prior_attrs present (would normally infer "update"), but meta.operation="create"
# overrides inference; create policy runs and passes because tag is present.
resource "aws_s3_bucket" "explicit_create_overrides_inference_passes" {
  expect_failure = false
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "prod"
    }
  }
  prior_attrs = {
    bucket = "old-name"
  }
}
