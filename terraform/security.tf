# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

data "aws_vpc" "default_vpc" {
  default = true
}

# Control Ansible Security Group
resource "aws_security_group" "ansible_sg" {
  name        = "${var.projectName}-control-sg"
  description = "Security group for Ansible"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-control-sg"
    Project = var.projectName
  }
}
