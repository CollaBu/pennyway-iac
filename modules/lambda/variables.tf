# lambda에서 실행할 함수 이름
variable "function_name" {
  type = string
}

# lambda에서 실행할 함수 이름
variable "function" {
  type = string
}

# lambda 함수의 layer
variable "layer" {
  type = string
}

# lambda 함수의 트리거 역할을 할 S3 버킷
variable "bucket" {
  type = object({
    id   = string
    name = string
    arn  = string
  })
}
