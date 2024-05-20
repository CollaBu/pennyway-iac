# 리소스명에서 참조되는 env_name(prod, dev, etc.)
variable "env_name" {
  type = string
}

# 서비스 도메인
variable "domain" {
  type = string
}

# 인증서 arn
variable "certificate_arn" {
  type = string
}
