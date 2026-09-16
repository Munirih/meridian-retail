variable "ec2_key_name" {
  description = "Name of an existing EC2 key pair. Leave empty to auto-generate one."
  type        = string
  default     = "my-aws-key"
}

variable "ec2_name" {
  description = "The name of the EC2 instance"
  type        = string
}


variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the EC2 instance in"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the EC2 instance in"
  type        = string
}

variable "environment" {
  description = "Enviroment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}


variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the EC2 instance"
  type        = string
}
