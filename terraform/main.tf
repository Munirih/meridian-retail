module "network" {
  source = "./modules/network"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment

}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

module "securitygroup" {
  source = "./modules/securitygroup"

  name   = var.sg_name
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      description = "Allow HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow SSH traffic"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
    },
    {
      description = "Allow HTTPS traffic"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Custom TCP for python flask app"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow PostgreSQL traffic"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = var.egress_rules
}

module "ecr_auth" {
  source = "./modules/ecr"

  name                 = var.auth_ecr_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "ecr_catalog" {
  source = "./modules/ecr"

  name                 = var.catalog_ecr_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "ecr_frontend" {
  source = "./modules/ecr"

  name                 = var.frontend_ecr_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "ecr_orders" {
  source = "./modules/ecr"

  name                 = var.orders_ecr_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "iam" {
  source = "./modules/iam"

  iam_role         = var.iam_role
  instance_profile = var.instance_profile
  postgres_backup_bucket_arn = module.s3_bucket.bucket_arn
}

module "ec2-instance" {
  source = "./modules/ec2-instance"

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  ec2_name          = var.ec2_name
  ec2_instance_type = var.ec2_instance_type
  ec2_key_name      = var.ec2_key_name
  security_group_id = module.securitygroup.security_group_id
  environment       = var.environment

  iam_instance_profile_name  = module.iam.instance_profile
  

}

module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = var.postgres_bucket_name
  environment = var.environment
}