# 호스팅 영역 리소스 - production
resource "aws_route53_zone" "zone_prod" {
  name = var.domain
}

# 호스팅 영역 리소스 - 개발 환경 
resource "aws_route53_zone" "name" {
  name = "dev.${var.domain}"
}
