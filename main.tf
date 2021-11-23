resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Mohit"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.30.1.0/24"

  tags = {
    Name = "Mohit"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Mohit"
  }
}

resource "aws_route_table" "pubilc" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Mohit"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.pubilc.id
}

resource "aws_instance" "app1" {
  # ami           = "ami-005e54dee72cc1d00" # us-west-2
  # ami           = "ami-053ac55bdcfe96e85" # us-west-1
  ami           = "ami-083654bd07b5da81d" # us-east-1
  #ami           = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh1.id]
  
  key_name = "ms-teraform-nov23"
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("$HOME/Downloads/ms-teraform-nov23.pem")
    #private_key = file("${path.module}/private_key.pem")
    host = self.public_ip
  }

  provisioner "file" {
    content = "Ami used - ami-083654bd07b5da81d"
    destination = "/tmp/file.log"
  }

  provisioner "remote-exec" {
      inline = [
          "echo '------'",
          "cat /tmp/file.log",
          "echo '------'"
      ]
  }

  tags = {
    Name = "Mohit-app1"
  }
}

resource "aws_security_group" "allow_ssh1" {
  name        = "allow_ssh1"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh1"
  }
}