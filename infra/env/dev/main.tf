data "aws_vpc" "default_vpc" {
  default = true
}

# Security Groups
module "ansible_sg" {
  source = "../../modules/security-group"

  name        = "ansible-sg"
  description = "Security group for Ansible"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress_rules = [
  ]
}

module "flask_sg" {
  source = "../../modules/security-group"

  name        = "flask-sg"
  description = "Security group for Flask"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress_rules = [
    {
    description          = "SSH from Ansible EC2"
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    security_group_ids   = [module.ansible_sg.id]
    },   
    {
    description          = "Access port 80 from everywhere"
    from_port            = 80
    to_port              = 80
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
    },   
    {
    description          = "Access from myIP"
    from_port            = 5000
    to_port              = 5000
    protocol             = "tcp"
    cidr_blocks          = ["${var.myIP}/32"]
    },    
    {
    description          = "Access from Prometheus to server app"
    from_port            = 5000
    to_port              = 5000
    protocol             = "tcp"
    security_group_ids = [module.prometheus_sg.id]
    },  
    {
    description          = "Access from Prometheus to node"
    from_port            = 9100
    to_port              = 9100
    protocol             = "tcp"
    security_group_ids = [module.prometheus_sg.id]
    },        
    {
    description          = "Node exporter from myIP"
    from_port            = 9100
    to_port              = 9100
    protocol             = "tcp"
    cidr_blocks          = ["${var.myIP}/32"]
    }
  ]
}

module "rds_sg" {
  source = "../../modules/security-group"

  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
    description          = "MySQL from Flask EC2"
    from_port            = 3306
    to_port              = 3306
    protocol             = "tcp"
    security_group_ids = [module.flask_sg.id]
    }
  ]
}

module "grafana_sg" {
  source = "../../modules/security-group"

  name        = "grafana-sg"
  description = "Security group for Grafana"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
    description          = "Grafana UI from myIP"
    from_port            = 3000
    to_port              = 3000
    protocol             = "tcp"
    cidr_blocks          = ["${var.myIP}/32"]
    },
    {
    description          = "Grafana from Ansible"
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    security_group_ids   = [module.ansible_sg.id]
    }    
  ]
}

module "prometheus_sg" {
  source = "../../modules/security-group"

  name        = "prometheus-sg"
  description = "Security group for Grafana"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
    description          = "Prometheus from Grafana"
    from_port            = 9090
    to_port              = 9090
    protocol             = "tcp"
    security_group_ids   = [module.grafana_sg.id]
    },
    {
    description          = "Prometheus UI from myIP"
    from_port            = 9090
    to_port              = 9090
    protocol             = "tcp"
    cidr_blocks          = ["${var.myIP}/32"]
    },
    {
    description          = "Prometheus from Ansible"
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    security_group_ids   = [module.ansible_sg.id]
    },    
  ]
}

module "loki_sg" {
  source = "../../modules/security-group"

  name        = "loki-sg"
  description = "Security group for Grafana"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
    description          = "Loki from Alloy"
    from_port            = 3100
    to_port              = 3100
    protocol             = "tcp"
    security_group_ids   = [module.flask_sg.id]
    },
    {
    description          = "Loki from Grafana"
    from_port            = 3100
    to_port              = 3100
    protocol             = "tcp"
    security_group_ids   = [module.grafana_sg.id]
    },    
    {
    description          = "Loki from Ansible"
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    security_group_ids   = [module.ansible_sg.id]
    },    
  ]
}