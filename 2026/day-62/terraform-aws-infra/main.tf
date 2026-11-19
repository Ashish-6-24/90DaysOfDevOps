
# --------------------------------------------------
# 1. VPC
# --------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

# --------------------------------------------------
# 2. Public Subnet
# --------------------------------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# --------------------------------------------------
# 3. Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

# --------------------------------------------------
# 4. Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "TerraWeek-Public-RT"
  }
}

# --------------------------------------------------
# 5. Route Table Association
# --------------------------------------------------

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------------------------------------
# 6. Security Group
# --------------------------------------------------

resource "aws_security_group" "ec2_sg" {
  name        = "TerraWeek-EC2-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

# --------------------------------------------------
# 7. EC2 Instance
# --------------------------------------------------

resource "aws_instance" "ec2" {
  ami                         = "ami-0231039d2b80be3ce"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.terraweek_key.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "TerraWeek-Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------
# 8. S3 Bucket
# --------------------------------------------------

resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-${var.environment}-${data.aws_caller_identity.current.account_id}-ap-southeast-2"

  depends_on = [
    aws_instance.ec2
  ]

  tags = {
    Name = "TerraWeek-app-logs"
  }
}

