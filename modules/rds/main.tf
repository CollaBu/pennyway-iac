# rds security-group 정의
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-rds-sg"
  }
}

# bastion에서 rds로 접근 허용
resource "aws_security_group_rule" "bastion_inbound_ssh" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.bastion_cidr]
  security_group_id = aws_security_group.rds_sg.id
}

# app 서브넷에서 오는 접근 허용
resource "aws_security_group_rule" "app_inbound_ssh" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.app_cidr_block]
  security_group_id = aws_security_group.rds_sg.id
}

# app 서브넷으로 나가는 트래픽 허용
resource "aws_security_group_rule" "data_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_sg.id
}

# rds subnet group 정의
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.terraform_name}-rds-subnet-group"
  subnet_ids = [var.subnet_id_1, var.subnet_id_2]

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-rds-subnet-group"
  }
}


# rds 리소스 정의
resource "aws_db_instance" "rds" {
  availability_zone     = "ap-northeast-2a"
  identifier            = "${var.terraform_name}-${var.env_name}-rdb"
  engine                = "mysql"
  engine_version        = "8.0.35"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = aws_db_parameter_group.rds_parameter.name
  skip_final_snapshot   = true
  publicly_accessible   = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-rds"
  }
}

# rds 파라미터 정의
resource "aws_db_parameter_group" "rds_parameter" {
  name = "rds-pg-${var.env_name}"
  family = "mysql8.0.35"
  description = "MySQL 8.0.35 Custom Parameter Group"

  parameter {
    name = "innodb_ft_min_token_size"
    value = "2"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = {
    Environment = var.env_name
    Terraform   = "true"
  }
}