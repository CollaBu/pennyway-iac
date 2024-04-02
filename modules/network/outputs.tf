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

# alb를 사용하기 위한 AZ가 다른 두 개의 public subnet
output "net1_id" {
  value = aws_subnet.net.id
}

output "net2_id" {
  value = aws_subnet.net2.id
}
