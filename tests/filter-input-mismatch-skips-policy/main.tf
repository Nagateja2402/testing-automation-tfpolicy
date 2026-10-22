# filter-input-mismatch-skips-policy: resource_policy filter attrs.engine_name==input.engine is false (postgres vs mysql): policy skipped, not failed
# tfp plan: PASS
# tfp apply: N/A
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_dms_endpoint" "e" {
  endpoint_id   = "filter-input-mismatch-skips-policy-endpoint"
  endpoint_type = "source"
  engine_name   = "postgres"
  server_name   = "example.invalid"
  port          = 5432
  username      = "u"
  password      = "notasecret123"
}
