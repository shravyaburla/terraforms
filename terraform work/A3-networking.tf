# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create Subnet in AZ1
resource "aws_subnet" "subnet_az1" {
  vpc_id                  = aws_vpc.main.id  # Ensure it's the same VPC
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-az1"
  }
}

# Create Subnet in AZ2
resource "aws_subnet" "subnet_az2" {
  vpc_id                  = aws_vpc.main.id  # Ensure it's the same VPC
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-az2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Route Table for Public Subnets to direct traffic to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# Create Route to Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Route Table Association for Subnets
resource "aws_route_table_association" "subnet_az1_association" {
  subnet_id      = aws_subnet.subnet_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_az2_association" {
  subnet_id      = aws_subnet.subnet_az2.id
  route_table_id = aws_route_table.public.id
}
# Security Group for ALB (Allow HTTP traffic)
resource "aws_security_group" "allow_alb" {
  name        = "allow_alb"
  description = "Allow access to ALB"
  vpc_id      = aws_vpc.main.id  # Ensure it's in the correct VPC

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "allow_alb"
  }
}

# Security Group for EC2 Instances (Allow HTTP access from ALB)
resource "aws_security_group" "allow_ec2" {
  name        = "allow_ec2"
  description = "Allow access to EC2 from ALB"
  vpc_id      = aws_vpc.main.id  # Ensure it's in the correct VPC

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_alb.id]  # Allow traffic from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ec2"
  }
}
