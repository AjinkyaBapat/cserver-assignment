provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_key_pair" "csv_server" {
  key_name   = "ubuntu"
  public_key = file("mykey.pub")
}

resource "aws_security_group" "csv_server" {
  name        = "ubuntu-security-group"
  description = "Allow App Server, Prometheus and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App"
    from_port   = 9393
    to_port     = 9393
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "csv_server" {
  ami                    = "ami-0d758c1134823146a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.csv_server.id]
  key_name               = "ubuntu"

  tags = {
    Name = "Ubuntu Instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update -y
    sudo apt install -y docker-ce
    sudo usermod -aG docker ubuntu
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    EOF


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("mykey")
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 10
  }
}

resource "aws_eip" "csv_server" {
  vpc      = true
  instance = aws_instance.csv_server.id
}
