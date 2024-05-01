resource "aws_s3_bucket" "storage" {
  bucket = "s3.${var.env_name}.${var.domain}"
}
