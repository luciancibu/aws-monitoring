# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# https://developer.hashicorp.com/terraform/language/provisioners

# Control Ansible
resource "aws_instance" "ansible_ec2" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.monitoringKeypair.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  availability_zone      = var.zone

  
  root_block_device {
  volume_size = 20     
  volume_type = "gp3"
  delete_on_termination = true
  }

  user_data = <<-EOF
  #!/bin/bash
  set -xe

  apt update -y
  apt install -y software-properties-common
  add-apt-repository --yes --update ppa:ansible/ansible
  apt install -y ansible
  apt install -y tree nano vim git zip unzip python3 python3-pip

  EOF

  tags = {
    Name    = "${var.projectName}-control"
    Project = var.projectName
    os = "ubuntu"
  }
}

resource "aws_ec2_instance_state" "ansible_ec2-state" {
  instance_id = aws_instance.ansible_ec2.id
  state       = "running"
}

# Flask
resource "aws_instance" "python_flask" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.monitoringKeypair.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  availability_zone      = var.zone
  iam_instance_profile = aws_iam_instance_profile.secret_manager_profile.name

  user_data = <<-EOF
  #!/bin/bash
  set -xe

  apt update -y
  apt install -y unzip curl
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o "/tmp/awscliv2.zip"
  cd /tmp
  unzip awscliv2.zip
  ./aws/install      
  EOF


  root_block_device {
  volume_size = 10     
  volume_type = "gp3"
  delete_on_termination = true
  }

  tags = {
    Name    = "${var.projectName}-flask"
    Project = var.projectName
    os = "ubuntu"
  }
}

resource "aws_ec2_instance_state" "python_flask-state" {
  instance_id = aws_instance.python_flask.id
  state       = "running"
}


# Grafana
resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.monitoringKeypair.key_name
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
  availability_zone      = var.zone

  tags = {
    Name    = "${var.projectName}-grafana"
    Project = var.projectName
    os = "ubuntu"
  }
}

resource "aws_ec2_instance_state" "grafana-state" {
  instance_id = aws_instance.grafana.id
  state       = "running"
}