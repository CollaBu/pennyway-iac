# AWS 계정의 액세스 키 ID
variable "access_key" {
  description = "AWS accesskey"
  type        = string
}

# AWS 계정의 시크릿 액세스 키 ID
variable "secret_key" {
  description = "AWS accesskey"
  type        = string
}

# AWS region
variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

# 리소스명에 참조될 region의 별명 설정
variable "region_name" {
  description = "AWS region name"
  default     = "apne2"
}

# 리소스명에 참조될 terraform의 별명(서비스명) 설정
variable "terraform_name" {
  default = "pennyway"
}

# 리소스명에 참조될 env의 별명 설정
variable "env_name_dev" {
  default = "dev"
}

# 네트워크 환경 설정에 사용되는 cidr block 설정
variable "cidr_block" {
  type = string
}

# bastion 서버에 접속하기 위해 사용되는 IP 주소
variable "remote_ip" {
  type = string
}

# AWS EC2 인스턴스에 SSH 접속을 위해 사용되는 키 쌍
variable "keypair" {
  type = string
}
