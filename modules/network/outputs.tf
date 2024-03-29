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
