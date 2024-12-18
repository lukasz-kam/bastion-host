resource "aws_security_group" "bas_sg" {
  name_prefix = "bas-sg-"

  ingress {
    from_port   = 22 #37271
    to_port     = 22 #37271
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_security_group" "sec_sg" {
  name_prefix = "sec-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ["${aws_instance.bastion_instance.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_key_pair" "gh_key" {
  key_name   = var.tf_key_name
  public_key = tls_private_key.ed_key.public_key_openssh
}

resource "tls_private_key" "ed_key" {
  algorithm = "ED25519"
}

resource "local_file" "TF-key" {
  content = tls_private_key.ed_key.private_key_openssh
  filename = var.ssh_key_filename
  file_permission = "0400"
}

resource "aws_instance" "bastion_instance" {
  ami           = "ami-04b54ebf295fe01d7"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.bas_sg.name]

  associate_public_ip_address = true

  key_name = var.tf_key_name

  tags = {
    Name = "BastionInstance"
  }
}

resource "aws_instance" "secured_instance" {
  ami           = "ami-04b54ebf295fe01d7"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.sec_sg.name]

  associate_public_ip_address = true

  key_name = var.tf_key_name

  tags = {
    Name = "SecuredInstance"
  }
}

resource "null_resource" "append_to_file" {
  provisioner "local-exec" {
    command = <<EOT
      echo "bastion ansible_host=${aws_instance.bastion_instance.public_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=$(pwd)/${var.ssh_key_filename}" > ../ansible/inventory.ini
      echo "secured ansible_host=${aws_instance.secured_instance.public_ip} private_ip=${aws_instance.secured_instance.private_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=$(pwd)/${var.ssh_key_filename}" >> ../ansible/inventory.ini
    EOT
  }
}
