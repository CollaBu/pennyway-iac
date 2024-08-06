# vpc 리소스 정의
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-vpc"
  }
}

# vpc에서 사용되는 internet_gateway 정의
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-igw"
  }
}

# NAT Gateway에 할당할 IP
resource "aws_eip" "ngw_ip" {
  domain = "vpc"
}

# NAT Gateway 선언
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.net.id
}

# net subnet 정의(nat, bastion이 이에 속함)
resource "aws_subnet" "net" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 0)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-net-public"
  }
}

# net subnet2 정의(nat, bastion이 이에 속함)
resource "aws_subnet" "net2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-net-public"
  }
}

# app subnet 정의(web, was가 이에 속함)
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-app-private"
  }
}

# data subnet 정의(rds, elasticcache 등이 이에 속함)
resource "aws_subnet" "data" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-data-private"
  }
}

# net subnet에서 사용되는 route_table 정의
resource "aws_route_table" "net" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-net-rtb"
  }
}

# net subnet과 route_table을 연결
resource "aws_route_table_association" "net" {
  subnet_id      = aws_subnet.net.id
  route_table_id = aws_route_table.net.id
}

# app subnet에서 사용되는 route_table 정의
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-app-rtb"
  }
}

resource "aws_route" "outbound_nat_route" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# app subnet과 route_table을 연결
resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

# bastion 서버의 security-group 정의
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion-sg"
  }
}

# bastion 서버에서 net 서브넷에서 오는 접근 허용
resource "aws_security_group_rule" "bastion_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.remote_ip]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버에서 http 접근 허용
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버에서 https 접근 허용
resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버에서 vpn 접근 허용
resource "aws_security_group_rule" "ovpn" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버에서 net 서브넷에서 오는 접근 허용
resource "aws_security_group_rule" "vpc_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [cidrsubnet(var.cidr_block, 8, 0)]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버의 모든 outbound 허용
resource "aws_security_group_rule" "bastion_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# AWS AMI 이미지 데이터 검색
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# bastion 서버(EC2) 생성
resource "aws_instance" "bastion" {
  ami                         = "ami-00e557080ac814181"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.net.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.keypair

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion"
  }
}

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

# 개발 환경에서 HTTP 및 HTTPS 트래픽을 컨트롤하기 위한 ALB 생성
resource "aws_lb" "alb" {
  name               = "${var.terraform_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.bastion_sg.id
  ]
  subnets = [
    aws_subnet.net.id,
    aws_subnet.net2.id
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert_dev.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# 운영 환경 인증서 추가
resource "aws_lb_listener_certificate" "https_cert_prod" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.cert_prod.arn
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = "bastion"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/v3/api-docs"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "bastion" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.bastion.id
  port             = 80
}

# 운영 환경 - bastion 호스트 연결
resource "aws_route53_record" "prod_to_bastion" {
  zone_id = aws_route53_zone.zone_prod.zone_id
  name    = "*.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# 개발 환경 - bastion 호스트 연결
resource "aws_route53_record" "dev_to_bastion" {
  zone_id = aws_route53_zone.zone_dev.zone_id
  name    = "*.dev.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# 개발 환경 - Storage(S3) 연결
resource "aws_route53_record" "dev_to_storage" {
  zone_id = aws_route53_zone.zone_dev.zone_id
  name    = "s3.dev.${var.domain}"
  type    = "A"

  alias {
    name                   = var.bucket_website_endpoint
    zone_id                = var.bucket_zone_id
    evaluate_target_health = false
  }
}

# 운영 환경 도메인 인증서 생성
resource "aws_acm_certificate" "cert_prod" {
  domain_name       = var.domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# 개발 도메인 인증서 생성
resource "aws_acm_certificate" "cert_dev" {
  domain_name       = "*.dev.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.dev.${var.domain}", # 와일드카드 서브도메인
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# CDN용 개발 도메인 인증 생성
resource "aws_acm_certificate" "cert_dev_cdn" {
  provider          = aws.us_east_1
  domain_name       = "*.dev.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.dev.${var.domain}", # 와일드카드 서브도메인
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# 운영 도메인 및 하위 도메인의 DNS 레코드 생성
resource "aws_route53_record" "validation_prod" {
  for_each = {
    for dvo in aws_acm_certificate.cert_prod.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone_prod.zone_id

  lifecycle {
    create_before_destroy = true
  }
}


# 개발 도메인 및 하위 도메인의 DNS 레코드 생성
resource "aws_route53_record" "validation_dev" {
  for_each = {
    for dvo in aws_acm_certificate.cert_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.zone_dev.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# 운영 도메인 인증서 검증
resource "aws_acm_certificate_validation" "validation_prod" {
  certificate_arn         = aws_acm_certificate.cert_prod.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_prod : record.fqdn]
}

# 개발 도메인 인증서 검증
resource "aws_acm_certificate_validation" "validation_dev" {
  certificate_arn         = aws_acm_certificate.cert_dev.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_dev : record.fqdn]
}

# 운영 환경 도메인 접속 시 개발 환경으로 연결
resource "aws_route53_record" "main_to_dev" {
  zone_id = aws_route53_zone.zone_prod.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# 개발 환경 - CDN 연결
resource "aws_route53_record" "cdn" {
  zone_id = aws_route53_zone.zone_dev.zone_id
  name    = "cdn.dev.${var.domain}"
  type    = "A"

  alias {
    name                   = var.cdn_domain_name
    zone_id                = var.cdn_zone_id
    evaluate_target_health = false
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
