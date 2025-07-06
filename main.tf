provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "docker_host" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io curl
    mkdir -p /home/ubuntu
    curl -o /home/ubuntu/index.html ${var.app_source_url}
    systemctl start docker
    systemctl enable docker
    docker run -d -p 80:80 -v /home/ubuntu:/usr/share/nginx/html nginx
  EOF

  tags = var.docker_host_tags
}
