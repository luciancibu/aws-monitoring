variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "myIP" {
  default = "188.24.56.231"
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    description        = string
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_group_ids = optional(list(string))
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
