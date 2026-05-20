# GR-DEP-009: Multi-attribute filter partial match returns empty — failure case
# name is config-known; "db-sg" != "web-sg" → no match → deny at plan and apply

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
  tags = { Name = "gr-dep-009-vpc" }
}

# Only a db-sg exists; web-sg is missing intentionally
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_s3_bucket" "main" {
  bucket        = "gr-dep-009-main-bucket-xyz"
  force_destroy = true
}
