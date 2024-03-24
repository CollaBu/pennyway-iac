# was 서버의 security-group 정의
resource "aws_security_group" "compute_sg" {
  description = "Security Group for test instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-${var.name}-sg"
  }
}

# was 서버는 bastion을 통해서만 접근할 수 있음
resource "aws_security_group_rule" "compute_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.compute_sg.id
}

# was 서버의 모든 outbound 허용
resource "aws_security_group_rule" "compute_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.compute_sg.id
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

# was 서버(EC2) 생성
resource "aws_instance" "compute" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.compute_sg.id]
  key_name               = var.keypair

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-${var.name}"
  }
}
