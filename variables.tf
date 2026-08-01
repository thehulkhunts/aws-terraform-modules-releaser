//variables for security groups

variable "security_groups" {
  description = "vpc-security-groups"
  type = map(object({

    description = string

    ingress_rules = list(object({

      from_port = number
      to_port = number
      protocol = string
      description = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({

      from_port = number
      to_port = number
      protocol = string
      description = string
      cidr_blocks = list(string)

    }))
      
  }))
}

variable "vpc_id" {
  type = string
  description = "vpc_id to interpolate"
}

//adding reusable tags for resources
variable "tags" {
  description = "Common tags for all security groups"
  type        = map(string)
  default     = {}
}