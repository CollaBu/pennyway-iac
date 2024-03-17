# vpc 리소스 정의
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

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

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-net-rtb"
  }
}

# net subnet은 모든 접근을 허용함
resource "aws_route" "net" {
  route_table_id         = aws_route_table.net.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
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

# app subnet과 route_table을 연결
resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}
