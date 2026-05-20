
policytest {
  targets = ["getresources_partial_filter.policy.hcl"]
}

# Only a db-sg exists, not the required web-sg
resource "aws_security_group" "db_sg" {
  skip = true
  attrs = {
    vpc_id = "vpc-static-001"
    name   = "db-sg"
  }
}

resource "aws_s3_bucket" "fail_no_web_sg" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
  }
}
