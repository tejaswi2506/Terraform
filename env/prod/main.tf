terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Project     = var.name_prefix
  }
}

module "vpc" {
  source              = "../../modules/vpc"
  name_prefix         = var.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az                  = var.az
  tags                = local.tags
}

module "ec2" {
  source           = "../../modules/ec2"
  name_prefix      = var.name_prefix
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id

  instance_type    = var.instance_type
  ami_id           = var.ami_id
  key_name         = var.key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
  tags             = local.tags

  user_data = <<-USERDATA
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>${var.name_prefix} - module-based deploy</h1>" > /var/www/html/index.html
  USERDATA
}