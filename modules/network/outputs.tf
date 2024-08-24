# network 모듈에서 정의한 vpc의 id를 재사용하기 위한 선언
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# network 모듈에서 정의한 net subnet의 id를 재사용하기 위한 선언
output "subnet_net_id" {
  value = aws_subnet.net.id
}

# network 모듈에서 정의한 app subnet의 id를 재사용하기 위한 선언
output "subnet_app_id" {
  value = aws_subnet.app.id
}

# network 모듈에서 정의한 data subnet의 id를 재사용하기 위한 선언
output "subnet_data_id" {
  value = aws_subnet.app.id
}

# network 모듈에서 정의한 internet_gateway의 id를 재사용하기 위한 선언
output "igw_id" {
  value = aws_internet_gateway.igw.id
}

# network 모듈에서 정의한 bastion의 ip를 참조하기 위해 선언
output "bastion_cidr" {
  value = aws_subnet.net.cidr_block
}

# network 모듈에서 정의한 bastion의 ip를 참조하기 위해 선언
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

# CDN 개발 환경 인증서 arn
output "cert_cdn_arn" {
  value = aws_acm_certificate.cert_dev_cdn.arn
}

# RDS 접속을 위한 CIDR block
output "app_cidr_block" {
  value = aws_subnet.app.cidr_block
}

# RDS 서브넷 그룹을 위한 subnet id 1
output "data_subnet_id_1" {
  value = aws_subnet.data1.id
}

# RDS 서브넷 그룹을 위한 subnet id 2
output "data_subnet_id_2" {
  value = aws_subnet.data2.id
}
