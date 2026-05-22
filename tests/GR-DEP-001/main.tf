# GR-DEP-001: VPC with associated flow log — happy path
# tfp plan: PASS (vpc_id resolves at plan time, flow log found with traffic_type=ALL)
# tfp apply: PASS (all values resolved, flow log found with traffic_type=ALL)

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

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "gr-dep-001-flow-logs-v2"
  retention_in_days = 7
}

resource "aws_iam_role" "flow_log" {
  name = "gr-dep-001-flow-log-role-v2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "gr-dep-001-vpc" }
}

resource "aws_flow_log" "main" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.flow_log.arn
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
}
