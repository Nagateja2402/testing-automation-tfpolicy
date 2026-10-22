# basics-cross-file-inputs-helpers-ec2-blocks: inputs/helpers/s3/ec2 policy files share input+local: s3 (env=prod) passes, ec2 (env=dev) fails with shared-input message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "b" {
  bucket = "basics-cross-file-inputs-helpers-e-b-nagateja"
  tags   = { env = "prod" }
}
resource "aws_instance" "i" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  tags          = { env = "dev" }
}
