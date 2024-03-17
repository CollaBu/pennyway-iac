resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion-sg"
  }
}

resource "aws_security_group_rule" "remote_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.remote_ip]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "ovpn" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = [var.remote_ip]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "vpc-inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [cidrsubnet(var.vpc_cidr_block, 8, 0)]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

data "aws_ami" "fck-nat-amzn2" {
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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.fck-nat-amzn2.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.keypair

  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
    encrypted   = true
  }
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-bastion"
  }
}
