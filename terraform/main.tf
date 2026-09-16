module "network" {
  source = "./modules/network"

  vpc_name             = "meridian-retail"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  environment          = "dev"

}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

module "securitygroup" {
  source = "./modules/securitygroup"

  name   = "meridian-retail-server"
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

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "ecr_auth" {
  source = "./modules/ecr"

  name                 = "auth-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
}

module "ecr_catalog" {
  source = "./modules/ecr"

  name                 = "catalog-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
}

module "ecr_frontend" {
  source = "./modules/ecr"

  name                 = "frontend-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
}

module "ecr_orders" {
  source = "./modules/ecr"

  name                 = "orders-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
}

module "iam" {
  source = "./modules/iam"

  iam_role         = "meridian-ec2-role"
  instance_profile = "meridian-ec2-instance-profile"
}

module "ec2-instance" {
  source = "./modules/ec2-instance"

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  ec2_name          = "meridian-retail-server"
  ec2_instance_type = "t3.micro"
  ec2_key_name      = var.ec2_key_name
  security_group_id = module.securitygroup.security_group_id
  environment       = "dev"

  iam_instance_profile_name = module.iam.instance_profile

}