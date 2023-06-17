terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
  backend "s3" {
    bucket = "dev-state-vu-diep"
    key = "tf-github/terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}
   


# Configure the AWS Provider
provider "aws" {
    region = "us-west-1"
    access_key = var.access_key
    secret_key = var.secret_key
}



# Create Key-pair
resource "aws_key_pair" "tf-key-pair" {
  key_name = var.key_pair_name
  public_key = tls_private_key.rsa-key.public_key_openssh
}
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa-key.private_key_pem
  filename = "${var.key_pair_name}.pem"
}

# Aws instance
resource "aws_instance" "my-tf-server" {
  ami = "ami-0bd4d695347c0ef88"
  key_name = aws_key_pair.tf-key-pair.key_name
  instance_type = "t2.micro"
  tags = {
    Name= "my-server1"
  }
}

resource "aws_vpc" "my-server-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "production"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.my-server-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    name = "prod-subnet"
  }
}