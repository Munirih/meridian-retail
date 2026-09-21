# ---------- AMI DATA SOURCE ----------
data "aws_ami" "ubuntu_2604" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's Official AWS Account ID

  filter {
    name = "name"
    # Matches the exact standard image pattern for Resolute Raccoon (amd64)
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Matches amd64 
  }

}

resource "aws_eip" "ec2" {
  domain = "vpc"

  tags = {
    Name = "${var.ec2_name}-eip"
  }
}

# ---------- EC2 INSTANCE ----------
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu_2604.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.ec2_key_name


  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  iam_instance_profile = var.iam_instance_profile_name

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
  }
}

# ---------- ELASTIC IP ASSOCIATION ----------
resource "aws_eip_association" "ec2" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2.id
}

