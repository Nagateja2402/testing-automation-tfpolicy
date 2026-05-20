
policytest {
  targets = ["cycle_detection.policy.hcl"]
}

# These two resources reference each other creating a cycle
# bucket_a.attrs references bucket_b and bucket_b.attrs references bucket_a
resource "aws_s3_bucket" "bucket_a" {
  attrs = {
    bucket = aws_s3_bucket.bucket_b.bucket
  }
}

resource "aws_s3_bucket" "bucket_b" {
  attrs = {
    bucket = aws_s3_bucket.bucket_a.bucket
  }
}
