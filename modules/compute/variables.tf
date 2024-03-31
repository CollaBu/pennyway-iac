# vpc에서 사용되는 cidr_block
variable "cidr_block" {
  type = string
}

# 리소스명에서 참조되는 region_name
variable "region_name" {
  type = string
}

# 리소스명에서 참조되는 terraform_name(서비스명)
variable "terraform_name" {
  type = string
}

# 리소스명에서 참조되는 env_name(prod, dev, etc.)
variable "env_name" {
  type = string
}

# was에 접근하기 위해 사용되는 키 쌍
variable "keypair" {
  type = string
}

# was 리소스가 속한 vpc의 id
variable "vpc_id" {
  type = string
}

# was 리소스가 속한 subnet의 id
variable "subnet_id" {
  type = string
}

# ec2 인스턴스명
variable "name" {
  type = string
}

# bastion 호스트의 ip
variable "bastion_cidr" {
  type = string
}
