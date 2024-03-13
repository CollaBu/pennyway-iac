variable "access_key" {
  description = "AWS accesskey"
  type        = string
}

variable "secret_key" {
  description = "AWS accesskey"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "region_name" {
  description = "AWS region name"
  default     = "apne2"
}

variable "terraform_name" {
  default = "pennyway"
}

variable "env_name_dev" {
  default = "dev"
}

variable "vpc_cidr_block" {
  default = "10.42.0.0/16"
}
