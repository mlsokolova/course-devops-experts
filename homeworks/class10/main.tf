terraform {
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

#Use configuration from ~/.aws
#provider "aws" {
#  region = 
#  access_key = 
#  secret_key = 
#}

#  block that lets to name and compute values to reuse them repeatedly across the codebase
locals {
  instance_name = "Class10Instance"
}

#############################################
# IAM Role for EC2
#
# This role is assumed by the EC2 instance.
# It grants the instance permissions to call
# AWS APIs on behalf of the instance.
#############################################
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  # Trust policy:
  # Allows the EC2 service to assume this IAM role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

#############################################
# Attach the AWS-managed Systems Manager policy
#
# This policy allows the EC2 instance to:
# - Register with Systems Manager (SSM)
# - Receive commands from SSM
# - Start Session Manager sessions
#
# As a result, you can connect to the instance
# without an SSH key or opening port 22.
#############################################
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#############################################
# IAM Instance Profile
#
# EC2 instances cannot attach an IAM Role
# directly. Instead, AWS requires an
# Instance Profile, which acts as a container
# for exactly one IAM Role.
#############################################
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "class10-instance" {
  ami           = "ami-06067086cf86c58e6" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  availability_zone =  "us-east-1c"
  # Configure the root storage / mount point
  root_block_device {
    volume_size           = 100
    tags = {
      Name = "class10-root-volume"
    }
  }
  # Associate the IAM Instance Profile.
  # This makes the IAM role available to the instance.
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  tags = {
    Name = local.instance_name,
    Environment = "learn"
  }
}

output "ip" {
  value = aws_instance.class10-instance.public_ip
}

