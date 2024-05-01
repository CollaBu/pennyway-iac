# S3 버킷 엔드포인트
output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_domain
}

# S3 웹사이트의 zone_id 
output "bucket_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}
