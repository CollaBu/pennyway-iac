# 호스팅 영역 리소스
resource "aws_route53_zone" "zone" {
  name = var.domain
}
