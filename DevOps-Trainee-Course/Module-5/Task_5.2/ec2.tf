locals {
  name_prefix = "${var.project_name}-${var.env}"
}

data "aws_ami" "ubuntu" {
    owners = ["099720109477"]
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.ubuntu.id
  for_each = var.instance_configs
  instance_type = each.value
  security_groups = [aws_security_group.sg.name]
  key_name= "kon_terraform_key"
  user_data = "${file("user_data.sh")}"

  tags = {
    Name = "${local.name_prefix}-${each.key}-ec2"
  }
}

resource "aws_security_group" "sg" {
  name = "${local.name_prefix}-sg"

  dynamic "ingress" {
    for_each = [80, 22]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "deployer" {
  key_name = "kon_terraform_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = pathexpand("~/SSH_Keys/kon_terraform_key.pem")
  file_permission = "0400"
}