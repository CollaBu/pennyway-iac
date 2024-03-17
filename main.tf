provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "network" {
  source         = "./modules/network"
  vpc_cidr_block = var.cidr_block
  region_name    = var.region_name
  env_name       = var.env_name_dev
  terraform_name = var.terraform_name
}

module "bastion" {
  source         = "./modules/compute/bastion"
  vpc_id         = module.network.vpc_id
  vpc_cidr_block = var.cidr_block
  subnet_id      = module.network.subnet_net_id
  igw_id         = module.network.igw_id
  region_name    = var.region_name
  env_name       = var.env_name_dev
  terraform_name = var.terraform_name
  keypair        = var.keypair
  remote_ip      = var.remote_ip
}

module "was" {
  source         = "./modules/compute/was"
  vpc_id         = module.network.vpc_id
  vpc_cidr_block = var.cidr_block
  subnet_id      = module.network.subnet_net_id
  region_name    = var.region_name
  env_name       = var.env_name_dev
  terraform_name = var.terraform_name
  keypair        = var.keypair
}
