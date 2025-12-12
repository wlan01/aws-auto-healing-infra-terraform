terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# ---------------- VPC ----------------
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

# ---------------- Security ----------------
module "security" {
  source = "./modules/security"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  allowed_ssh_cidr_block = var.allowed_ssh_cidr_block
}

# ---------------- ALB ----------------
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

# ---------------- Compute (Launch Template + ASG) ----------------
module "compute" {
  source = "./modules/compute"

  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
  ec2_sg_id        = module.security.ec2_sg_id
  target_group_arn = module.alb.target_group_arn
}

# ---------------- Monitoring ----------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  asg_name     = module.compute.asg_name
}
