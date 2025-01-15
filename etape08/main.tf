# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
}

# Data source to get the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["*ubuntu-*24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Create a security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http_s" {
  name        = "allow_http_s"
  description = "Allow HTTP/S inbound traffic"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_s"
  }
}

# Create an EC2 instance
resource "aws_instance" "http" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = "myKey"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http_s.id]

  tags = {
    Name = "http"
  }
}

resource "aws_instance" "script" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = "myKey"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "script"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip_http" {
  value = aws_instance.http.public_ip
}

output "instance_private_ip_http" {
  value = aws_instance.http.private_ip
}

output "instance_public_ip_script" {
  value = aws_instance.script.public_ip
}

output "instance_private_ip_script" {
  value = aws_instance.script.private_ip
}

# Output the AMI ID used
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

# Write the output to a file
resource "local_file" "output_file" {
  content  = <<-EOT
Instance Public IP http   : ${aws_instance.http.public_ip}
Instance Public IP script : ${aws_instance.script.public_ip}
EOT
  filename = "${path.module}/output.txt"
}
