#------------ IAM ROLE ------------ 

resource "aws_iam_role" "iam_role" {
  name = var.iam_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#------------ ATTACH POLICY ------------ 

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


#------------ INSTANCE PROFILE ------------ 


resource "aws_iam_instance_profile" "instance_profile" {
  name = var.instance_profile
  role = aws_iam_role.iam_role.name
}
