variable "projectName" {
  default = "monitoring"
}

variable "region" {
  default = "us-east-1"
}

variable "zone" {
  default = "us-east-1a"
}

variable "myIP" {
  default = "188.24.56.231"
}

variable "instanceType" {
  default = "t3.micro"
}

variable "ansibleUserByOS" {
  type        = map(string)
  default = {
    ubuntu       = "ubuntu"
  }
}

variable "deployName" {
  default = "deployment_script.sh"
}
