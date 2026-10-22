variable "name" { type = string }
resource "aws_s3_bucket" "q" { bucket = var.name }
