variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "name of vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR address for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "environment" {
  description = "Enviroment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ec2_name" {
  description = "The name of the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = "my-aws-key"
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "egress_rules" {
  description = "A list of egress rules to apply to the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "frontend_ecr_name" {
  description = "The name of the ecr repository"
  type        = string
}

variable "orders_ecr_name" {
  description = "The name of the ecr repository"
  type        = string
}

variable "catalog_ecr_name" {
  description = "The name of the ecr repository"
  type        = string
}

variable "auth_ecr_name" {
  description = "The name of the ecr repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Whether to scan images when they are pushed to ECR"
  type        = bool
}

variable "iam_role" {
  description = "IAM role name"
  type        = string
}

variable "instance_profile" {
  description = "EC2 instance profile name"
  type        = string
}

variable "postgres_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

