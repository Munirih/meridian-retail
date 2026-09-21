variable "iam_role" {
  description = "IAM role name"
  type        = string
}

variable "instance_profile" {
  description = "EC2 instance profile name"
  type        = string
}

variable "postgres_backup_bucket_arn" {
  description = "ARN of the S3 bucket used for PostgreSQL backups"
  type        = string
}
