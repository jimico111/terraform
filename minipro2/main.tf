provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "./modules/vpc"

  name = "myVPC"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "asg" {
  source = "./modules/asg"

  name = "myASG"
  vpc_id = module.vpc.vpc_id
  vpc_zone_identifier = module.vpc.public_subnets_ids
  target_group_arns = [module.alb.target_group_arn]

  key_name = var.key_name

  db_address = module.db.db_address
  db_username = var.db_username
  db_password = var.db_password
}

module "alb" {
  source = "./modules/alb"

  name = "myALB"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets_ids
}

module "db" {
  source = "./modules/rds"

  name = "myDB"

  db_username = var.db_username
  db_password = var.db_password

  vpc_id = module.vpc.vpc_id
}