variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
  default = null
}

variable "private_subnets" {
  type = list(string)
  default = null
}

variable "allocated_storage" {
  type    = number
  default = 10
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "username" {
  type    = string
  default = "rds_username"
}

variable "password" {
  type    = string
  default = "rds_password"
  sensitive = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "security_group_id" {
  type = list(string)
}

variable "publicly_accessible" {
  type    = bool
}

variable "port" {
  type    = number
  default = 10
}