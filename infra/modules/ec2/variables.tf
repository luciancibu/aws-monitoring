variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "availability_zone" {
  type = string
}

variable "iam_instance_profile" {
  type = string
  default = null
}

variable "os" {
  type = string
}

variable "user_data" {
  type = string
  default = null
}

variable "root_block_device" {
  type = object({
    volume_size           = number
    volume_type           = string
    delete_on_termination = bool
  })
  default = null
}

variable "project" {
  type = string
}