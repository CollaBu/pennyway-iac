# bastion 서버의 security-group 정의
resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion-sg"
  }
}

# bastion 서버에 remote_ip의 SSH 접근 허용
resource "aws_security_group_rule" "remote_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.remote_ip]
  security_group_id = aws_security_group.bastion.id
}

# bastion 서버에서 ovpn을 사용
resource "aws_security_group_rule" "ovpn" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# bastion 서버에서 net 서브넷에서 오는 접근 허용
resource "aws_security_group_rule" "vpc-inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [cidrsubnet(var.cidr_block, 8, 0)]
  security_group_id = aws_security_group.bastion.id
}

# bastion 서버의 모든 outbound 허용
resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# AWS AMI 이미지 데이터 검색
data "aws_ami" "fck-nat-amzn2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["fck-nat-amzn2-hvm-1.1.0*-x86_64-ebs"]
  }
  filter {
    name   = "owner-id"
    values = ["568608671756"]
  }
}

# bastion 서버(EC2) 생성
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.fck-nat-amzn2.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  source_dest_check      = false
  key_name               = var.keypair

  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
    encrypted   = true
  }
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  instance = aws_instance.bastion.id
}

