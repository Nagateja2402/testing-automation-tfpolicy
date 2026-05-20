
policytest {
  targets = ["all_ops.policy.hcl"]
}

resource "aws_s3_bucket" "create_with_resource_name_passes" {
  expect_failure = false
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
}

resource "aws_s3_bucket" "update_with_resource_name_passes" {
  expect_failure = false
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
}

resource "aws_s3_bucket" "delete_with_resource_name_passes" {
  expect_failure = false
  meta = {
    operation = "delete"
  }
  attrs = {
    tags = {
      ResourceName = "my-bucket"
    }
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
}
