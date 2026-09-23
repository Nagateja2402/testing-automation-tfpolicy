# meta.operation must be a string ("create" | "update" | "delete"). Setting
# it to a number must be reported as a clean diagnostic (no crash / no panic
# stack trace) and the test run must exit non-zero.
resource "aws_s3_bucket" "bad_operation_type" {
  expect_failure = false
  attrs = { bucket = "some-bucket" }
  meta  = { provider_type = "aws", operation = 123 }
}
