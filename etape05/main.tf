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

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = "myKey"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-101"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

# Output the AMI ID used
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}
