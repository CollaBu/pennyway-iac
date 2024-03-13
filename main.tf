provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "dev_network" {
  source         = "./modules/network"
  vpc_cidr_block = var.vpc_cidr_block
  region_name    = var.region_name
  env_name       = var.env_name_dev
  terraform_name = var.terraform_name
}

