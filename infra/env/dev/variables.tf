variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "zone" {
  type = string
}

variable "projectName" {
  type = string
}

variable "instanceType" {
  type = string
}

variable "ansibleUserByOS" {
  type        = map(string)
  default = {
    ubuntu       = "ubuntu"
    debian       = "admin"
    redhat       = "ec2-user"
    amazonlinux  = "ec2-user"
  }
}

variable "myIP" {
  default = "188.24.56.231"
}
