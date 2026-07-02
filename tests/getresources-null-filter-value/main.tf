# EC-GR-003: getresources with null filter value (attrs.owner_id → null).
# At plan time: attrs.owner_id is computed/unknown → UNKNOWN
# At apply time: getresources with null returns empty list → length >= 0 → PASS

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
  tags = { Name = "ec-gr-003-vpc" }
}
