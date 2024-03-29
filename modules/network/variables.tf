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

# bastion에 접근하기 위해 사용되는 키 쌍
variable "keypair" {
  type = string
}

# bastion에 접근 가능한 ip
variable "remote_ip" {
  type = string
}
