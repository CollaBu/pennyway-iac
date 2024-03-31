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

# bastion 서버에서 vpn 접근 허용
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
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

# public ip를 통해 8080 포트 접근 허용
resource "aws_security_group_rule" "api" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# bastion 서버에서 net 서브넷에서 오는 접근 허용
resource "aws_security_group_rule" "vpc-inbound" {
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
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.net.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.keypair

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion"
  }
}
