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

# Flask Security Group
resource "aws_security_group" "flask_sg" {
  name        = "${var.projectName}-flask-sg"
  description = "Security group for flask"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description     = "SSH from Ansible EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_sg.id]
  }

  ingress {
    description = "SSH from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  ingress {
    description     = "Access from MyIP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks      = ["${var.myIP}/32"]
  } 

  ingress {
    description     = "Access from MyIP"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    cidr_blocks      = ["${var.myIP}/32"]
  } 

  ingress {
    description     = "Access from Prometheus"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus_sg.id]
  }

  ingress {
    description     = "Access from Alloy"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus_sg.id]
  }

  ingress {
    description     = "Access from myIP"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    cidr_blocks      = ["${var.myIP}/32"]
  }    
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-nginx-sg"
    Project = var.projectName
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name = "${var.projectName}-rds-sg"
  description = "Security group for RDS"
  vpc_id     = data.aws_vpc.default_vpc.id

  ingress {
    description     = "MySQL from Flask EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.flask_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-rds-sg"
    Project = var.projectName
  }
}

# Grafana Security Group
resource "aws_security_group" "grafana_sg" {
  name = "${var.projectName}-grafana-sg"
  description = "Security group for Grafana"
  vpc_id     = data.aws_vpc.default_vpc.id

  ingress {
    description     = "MySQL from Flask EC2"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  ingress {
    description     = "Grafana from Ansible"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-grafana-sg"
    Project = var.projectName
  }
}

# Prometheus Security Group
resource "aws_security_group" "prometheus_sg" {
  name = "${var.projectName}-prometheus-sg"
  description = "Security group for Prometheus"
  vpc_id     = data.aws_vpc.default_vpc.id

  ingress {
    description     = "Prometheus from Grafana"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana_sg.id]
  }

  ingress {
    description     = "Prometheus from my IP"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }  

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  ingress {
    description = "Prometheus from Ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ansible_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-prometheus-sg"
    Project = var.projectName
  }
}

# Loki Security Group
resource "aws_security_group" "loki_sg" {
  name = "${var.projectName}-loki-sg"
  description = "Security group for Loki"
  vpc_id     = data.aws_vpc.default_vpc.id

  ingress {
    description     = "Loki from Flask/Alloy"
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    security_groups = [aws_security_group.flask_sg.id]
  }

  ingress {
    description     = "Loki from Grafana"
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana_sg.id]
  }  

  ingress {
    description     = "Loki from my IP"
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }  

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  ingress {
    description = "Loki from Ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ansible_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-loki-sg"
    Project = var.projectName
  }
}