# aws ec2 describe-images \
#     --owners 099720109477 \
#     --filters "Name=name,Values=*ubuntu*24.04*amd64-server-*" "Name=state,Values=available" \
#     --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]' \
#     --output text \
#     --region us-east-1
# AMI : Amazon Machine Image

# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../_credentials/aws_learner_lab_credentials"]
  profile                  = "awslearnerlab"
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-02f7c3a0c32f3f59e"
  key_name      = "vockey"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-101"
  }
}
