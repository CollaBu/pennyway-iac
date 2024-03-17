resource "aws_security_group_rule" "bastion" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [cidrsubnet(var.vpc_cidr_block, 8, 0)]
  security_group_id = aws_security_group.was.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.was.id
}

resource "aws_security_group" "was" {
  description = "Security Group for test instance"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-was-sg"
  }
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

resource "aws_instance" "was" {
  ami                    = data.aws_ami.fck-nat-amzn2.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.was.id]
  source_dest_check      = false
  key_name               = var.keypair

  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
    encrypted   = true
  }
  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-was"
  }
}

