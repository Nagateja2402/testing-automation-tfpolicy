
policytest {
  targets = ["gr_in_filter.policy.hcl"]
}

resource "aws_flow_log" "fixture" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

# VPC with matching flow log — filter=true, enforce runs, tag present → passes
resource "aws_vpc" "filter_true_with_tag_passes" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
    tags = {
      Environment = "dev"
    }
  }
}

# VPC with no flow log — filter=false, enforce skipped → passes even without tag
resource "aws_vpc" "filter_false_no_flow_log_passes" {
  expect_failure = false
  attrs = {
    id         = "vpc-xyz999"
    cidr_block = "10.1.0.0/16"
    tags       = {}
  }
}

# VPC with matching flow log — filter=true, enforce runs, tag missing → fails
resource "aws_vpc" "filter_true_missing_tag_fails" {
  expect_failure = true
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.2.0.0/16"
    tags       = {}
  }
}
