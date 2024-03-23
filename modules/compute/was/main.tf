# was 서버의 security-group 정의
resource "aws_security_group" "was_sg" {
  description = "Security Group for test instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-was-sg"
  }
}

# was 서버는 bastion을 통해서만 접근할 수 있음
resource "aws_security_group_rule" "to_bastion" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.was_sg.id
}

# was 서버의 모든 outbound 허용
resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.was_sg.id
}

# AWS AMI 이미지 데이터 검색
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# was 서버(EC2) 생성
resource "aws_instance" "was" {
  ami                    = "ami-09a7535106fbd42d5"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.was_sg.id]
  key_name               = var.keypair

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-was"
  }
}
