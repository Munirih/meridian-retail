output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.network.vpc_name
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.securitygroup.security_group_id
}


output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2-instance.ec2_instance_id
}

output "ec2_elastic_ip" {
  description = "Elastic IP address of the EC2 server"
  value       = module.ec2-instance.elastic_ip
}

