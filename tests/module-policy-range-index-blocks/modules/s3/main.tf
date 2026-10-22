variable "bucket_name" { type = string }
variable "enable_versioning" { type = bool }
variable "sse_algorithm" { type = string }

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = {
    versioning = tostring(var.enable_versioning)
    sse        = var.sse_algorithm
  }
}
