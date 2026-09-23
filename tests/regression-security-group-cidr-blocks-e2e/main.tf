# REG-BIN: security group restricted to an internal CIDR — no public
# ingress — real plan+apply should PASS.

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

resource "aws_security_group" "main" {
  name        = "reg-bin-sg-cidr-blocks"
  description = "restricted ingress"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
