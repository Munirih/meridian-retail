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

resource "aws_iam_policy" "postgres_backup_s3" {
  name        = "meridian-retail-postgres-backup-s3"
  description = "Allow EC2 to upload and restore PostgreSQL backups from S3"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = "${var.postgres_backup_bucket_arn}/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = var.postgres_backup_bucket_arn
      }
    ]
  })
}

#------------ ATTACH POLICY ------------ 

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "postgres_backup_s3" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.postgres_backup_s3.arn
}
#------------ INSTANCE PROFILE ------------ 


resource "aws_iam_instance_profile" "instance_profile" {
  name = var.instance_profile
  role = aws_iam_role.iam_role.name
}


