# S3 버킷 리소스
resource "aws_s3_bucket" "bucket" {
  bucket = "s3.${var.env_name}.${var.domain}"
}

# S3 버킷의 Public Access Block 설정
resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 버킷 접근 제어 정책 설정
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        }
        Action = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

# 다른 계정에서 S3 버킷에 접근할 수 있도록 권한 설정
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

# S3 버킷 정적 웹사이트 호스팅 설정
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

# S3 버킷에 CDN 설정을 위한 Origin Access Identity 생성
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for my S3 bucket"
}

# S3 버킷에 대한 CDN 리소스 생성
resource "aws_cloudfront_distribution" "s3_cdn" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.arn
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for my S3 bucket"

  aliases = [
    "cdn.${var.env_name}.${var.domain}",
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.bucket.arn

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    max_ttl                = 43200 # 12 hours
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

# S3 버킷 Lifecycle 설정
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "delete-rule"

    filter {
      prefix = "delete/"
    }

    status = "Enabled"

    expiration {
      days = 2
    }
  }
}
