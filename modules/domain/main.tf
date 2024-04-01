# 호스팅 영역 리소스 - 운영 환경
resource "aws_route53_zone" "zone_prod" {
  name = var.domain
}

# 호스팅 영역 리소스 - 개발 환경 
resource "aws_route53_zone" "zone_dev" {
  name = "dev.${var.domain}"
}

# 운영 환경 - 개발 환경 호스팅 영역 분리
resource "aws_route53_record" "prod_to_dev" {
  zone_id = aws_route53_zone.zone_prod.zone_id
  name    = "dev.${var.domain}"
  type    = "NS"
  ttl     = "172800"
  records = aws_route53_zone.zone_dev.name_servers
}
