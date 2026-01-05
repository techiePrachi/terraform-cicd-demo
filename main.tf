terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
        }
    }
}

provider "aws"{
    region= "${var.region}"
}

resource "aws_vpc" "this"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "cicd-vpc"
    }
}

resource "aws_subnet" "this"{
    vpc_id = aws_vpc.this.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}


resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["183.83.53.239/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "phase1-web-sg"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "cicd-igw"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_instance" "web"{
    ami = var.ami
    instance_type = "t2.micro"
    subnet_id = aws_subnet.this.id
    tags = {
        Name = "terraform-cicd-demo"
    }
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
}

