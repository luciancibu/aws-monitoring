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

# Keypair
module "keypair" {
  source = "../../modules/keypair"

  project_name = var.projectName
  output_path = "${local.ansible_dir}/"
}
# IAM
module "iam" {
  source = "../../modules/iam"

  project_name       = var.projectName
}

# Instances
module "ansible_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-ansible"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.ansible_sg.id]
  availability_zone     = var.zone

  root_block_device = {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/../../modules/user-data/ansible.sh")
}

module "flask_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-flask"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.flask_sg.id]
  availability_zone     = var.zone
  iam_instance_profile = module.iam.ec2_instance_profile_name

  root_block_device = {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

module "grafana_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-grafana"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.grafana_sg.id]
  availability_zone     = var.zone
}

module "loki_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-loki"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.loki_sg.id]
  availability_zone     = var.zone
}

module "prometheus_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-prometheus"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.prometheus_sg.id]
  availability_zone     = var.zone
}

# RDS
module "rds" {
  source = "../../modules/rds"

  name = var.projectName
  publicly_accessible = true
  security_group_id = [module.rds_sg.id]
}

# Inventory template
resource "local_file" "ansible_inventory" {
  filename = "${local.ansible_dir}/inventory"

content = templatefile("${path.root}/../../templates/inventory.tmpl", {
  clientkey = module.keypair.key_name

  python_ip  = module.flask_ec2.private_ip
  python_user  = var.ansibleUserByOS[module.flask_ec2.os]
  python_ip_public  = module.flask_ec2.public_ip

  grafana_ip  = module.grafana_ec2.private_ip
  grafana_user  = var.ansibleUserByOS[module.prometheus_ec2.os]  

  prometheus_ip  = module.grafana_ec2.private_ip
  prometheus_user  = var.ansibleUserByOS[module.prometheus_ec2.os]

  loki_ip  = module.loki_ec2.private_ip
  loki_user  = var.ansibleUserByOS[module.loki_ec2.os]
})
}

# Deployment script template
resource "local_file" "deployment_script" {
  filename = "${local.project_root_dir}/deployment_script.sh"

content = templatefile("${path.root}/../../templates/deploy.tmpl", {
  clientkey = module.keypair.key_name

  ansible_pub_ip  = module.ansible_ec2.public_ip
  ansible_user  = var.ansibleUserByOS[module.ansible_ec2.os]
})
}