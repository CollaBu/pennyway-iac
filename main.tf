# AWS를 Provider로 설정
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# VPC, Subnet 등 네트워크 환경 구축
module "network" {
  source                  = "./modules/network"
  cidr_block              = var.cidr_block
  region_name             = var.region_name
  env_name                = var.env_name_dev
  terraform_name          = var.terraform_name
  keypair                 = var.keypair
  remote_ip               = var.remote_ip
  domain                  = var.domain
  bucket_website_endpoint = module.storage.bucket_website_endpoint
  bucket_zone_id          = module.storage.bucket_zone_id
  cdn_domain_name         = module.storage.cdn_domain_name
  cdn_zone_id             = module.storage.cdn_zone_id
}

# was 서버 구축
module "was" {
  source         = "./modules/compute"
  vpc_id         = module.network.vpc_id
  name           = "was"
  cidr_block     = var.cidr_block
  subnet_id      = module.network.subnet_app_id
  region_name    = var.region_name
  env_name       = var.env_name_dev
  terraform_name = var.terraform_name
  keypair        = var.keypair
  bastion_cidr   = module.network.bastion_cidr
}

# serverless web 인스턴스 구축
module "amplify_web" {
  source              = "./modules/amplify_web"
  github_access_token = var.github_access_token
}

# S3 버킷 구축
module "storage" {
  source          = "./modules/storage"
  env_name        = var.env_name_dev
  domain          = var.domain
  certificate_arn = module.network.cert_cdn_arn
}

# Lambda 함수 구축 - S3 이미지 리사이저 - Profile
module "lambda" {
  source        = "./modules/lambda"
  function_name = "s3_image_resizer"
  function      = "lambda_functions/image-resizer/"
  layer         = "lambda_layers/image_resizer.zip"
  bucket        = module.storage.bucket
}
