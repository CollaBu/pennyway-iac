# S3 버킷 엔드포인트
output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_domain
}

# S3 웹사이트의 zone_id 
output "bucket_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}

# CDN의 domain_name
output "cdn_domain_name" {
  value = aws_cloudfront_distribution.s3_cdn.domain_name
}

# CDN의 zone_id
output "cdn_zone_id" {
  value = aws_cloudfront_distribution.s3_cdn.hosted_zone_id
}

# S3 버킷
output "bucket" {
  value = {
    id   = aws_s3_bucket.bucket.id
    name = aws_s3_bucket.bucket.bucket
    arn  = aws_s3_bucket.bucket.arn
  }
}
