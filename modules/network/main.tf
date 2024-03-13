resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-igw"
  }
}

resource "aws_subnet" "net" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 0)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-net-public"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-app-private"
  }
}

resource "aws_subnet" "data" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 2)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.region_name}-${var.terraform_name}-${var.env_name}-data-private"
  }
}

resource "aws_route_table" "net" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public rtb"
  }
}

resource "aws_route" "net" {
  route_table_id         = aws_route_table.net.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "net" {
  subnet_id      = aws_subnet.net.id
  route_table_id = aws_route_table.net.id
}
