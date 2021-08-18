terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.default_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_prefix

  tags = {
      Name = "main-vpc"
  }
}

# Create a Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
  }
}

# Create a Routing Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-rt"
  }

  depends_on = [
    aws_internet_gateway.gw,
  ]
}

# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_prefix
  availability_zone = var.default_availability_zone

  tags = {
    Name = "main-subnet"
  }
}

# Associate the Routing Table with the Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a Secuirty Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "SSH Traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "HTTP Traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "HTTPS Traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "Default Egress Rule"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}

# Create a Network Interface
resource "aws_network_interface" "int-1" {
  subnet_id       = aws_subnet.main.id
  private_ips     = var.local_ips
  security_groups = [aws_security_group.allow_ssh.id]
}

# Create an EIP
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.int-1.id
  associate_with_private_ip = var.local_ips[0]

  depends_on = [
    aws_internet_gateway.gw,
  ]
}

# Create a VM
resource "aws_instance" "test-server" {
  ami = var.default_ami
  instance_type = var.default_instance_type
  availability_zone = var.default_availability_zone
  key_name = var.default_ssh_key

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.int-1.id
  }

  user_data = templatefile("${path.module}/script.sh", { tstamp = "${local.timestamp}" })

  depends_on = [
    aws_eip.one
  ]

}

output "public-ip" {
  value = aws_eip.one.public_ip
}
