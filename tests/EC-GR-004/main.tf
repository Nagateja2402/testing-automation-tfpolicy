# EC-GR-004: getresources with wrong type for filter value (number 12345 instead of string).
# Filter value is a literal number — config-known at plan time.
# At plan time: getresources("aws_flow_log", {vpc_id = 12345}) → no match → length >= 0 → PASS
# At apply time: same → PASS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ec-gr-004-vpc" }
}
