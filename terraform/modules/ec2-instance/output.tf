output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "elastic_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.ec2.public_ip
}





