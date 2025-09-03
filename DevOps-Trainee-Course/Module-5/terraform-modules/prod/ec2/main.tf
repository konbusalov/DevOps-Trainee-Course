locals {
    ingress_rules = [
        {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            from_port = -1
            to_port = -1
            protocol = "icmp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
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
    instance_type = "t3.micro"
    subnet_id = data.terraform_remote_state.vpc.outputs.subnet_ids[0]
    vpc_security_group_ids = [aws_security_group.sg.id]
    associate_public_ip_address = "true"
    key_name = "kon_terraform_key"
    

    tags = {
        Name = "prod-trainee-project-ec2"
    }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "deployer" {
  key_name = "kon_terraform_key_prod"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = pathexpand("~/SSH_Keys/kon_terraform_key_prod.pem")
  file_permission = "0400"
}

resource "aws_security_group" "sg" {
    name = "prod-trainee-project-sg"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

    dynamic ingress {
        for_each = local.ingress_rules
        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }
}