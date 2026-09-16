output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile.name
}

output "iam_role" {
  value = aws_iam_role.iam_role.name
}

